# frozen_string_literal: true

module Enumerize
  module ActiveRecordSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if self < ::ActiveRecord::Base
          include InstanceMethods
          extend Rails6ClassMethods if Rails::VERSION::MAJOR >= 6

          const_get(:ActiveRecord_Relation).include(RelationMethods)
          const_get(:ActiveRecord_AssociationRelation).include(RelationMethods)
          const_get(:ActiveRecord_Associations_CollectionProxy).include(RelationMethods)

          # Since Rails use `allocate` method on models and initializes them with `init_with` method.
          # This way `initialize` method is not being called, but `after_initialize` callback always gets triggered.
          after_initialize :_set_default_value_for_enumerized_attributes

          # https://github.com/brainspec/enumerize/issues/111
          require 'enumerize/hooks/uniqueness'

          unless options[:multiple]
            decorate_attribute_type(name, :enumerize) do |subtype|
              Type.new(enumerized_attributes[name], subtype)
            end
          end
        end
      end
    end

    module AttributeSubstitution
      def subs_enumerized_values(values)
        if values.is_a?(Hash)
          enumerized_attributes.each do |attr|
            next if values[attr.name].blank? || attr.kind_of?(Enumerize::Multiple)
            enumerize_value = attr.find_value(values[attr.name])
            values[attr.name] = enumerize_value && enumerize_value.value
          end
        end
        values
      end
    end

    module InstanceMethods
      # https://github.com/brainspec/enumerize/issues/74
      def write_attribute(attr_name, value, *options)
        if self.class.enumerized_attributes[attr_name]
          _enumerized_values_for_validation[attr_name.to_s] = value
        end

        super
      end

      # Support multiple enumerized attributes
      def becomes(klass)
        became = super
        klass.enumerized_attributes.each do |attr|
          # Rescue when column associated to the enum does not exist.
          begin
            became.send("#{attr.name}=", send(attr.name))
          rescue ActiveModel::MissingAttributeError
          end
        end

        became
      end

      def reload(options = nil)
        reloaded = super

        reloaded.class.enumerized_attributes.each do |attr|
          begin
            # Checks first if the enumerized attribute is in ActiveRecord::Store
            store_attr, _ = reloaded.class.stored_attributes.detect do |store_attr, keys|
              keys.include?(attr.name)
            end

            if store_attr.present?
              reloaded.send("#{attr.name}=", reloaded.send(store_attr).with_indifferent_access[attr.name])
            else
              reloaded.send("#{attr.name}=", reloaded[attr.name])
            end
          rescue ActiveModel::MissingAttributeError
          end
        end

        reloaded
      end
    end

    module Rails6ClassMethods
      include AttributeSubstitution

      def insert_all(attributes, returning: nil, unique_by: nil)
        super(
          attributes.map { |values| subs_enumerized_values(values) },
          returning: returning,
          unique_by: unique_by
        )
      end

      def insert_all!(attributes, returning: nil)
        super(
          attributes.map { |values| subs_enumerized_values(values) },
          returning: returning
        )
      end

      def upsert_all(attributes, returning: nil, unique_by: nil)
        super(
          attributes.map { |values| subs_enumerized_values(values) },
          returning: returning,
          unique_by: unique_by
        )
      end
    end

    module RelationMethods
      include AttributeSubstitution

      def update_all(updates)
        super(subs_enumerized_values(updates))
      end
    end

    class Type < ActiveRecord::Type::Value
      delegate :type, to: :@subtype

      def initialize(attr, subtype)
        @attr = attr
        @subtype = subtype
      end

      def serialize(value)
        v = @attr.find_value(value)
        (v && v.value) || value
      end

      alias type_cast_for_database serialize

      def deserialize(value)
        @attr.find_value(value)
      end

      alias type_cast_from_database deserialize

      def as_json(options = nil)
        {attr: @attr.name, subtype: @subtype}.as_json(options)
      end

      def encode_with(coder)
        coder[:class_name] = @attr.klass.name
        coder[:attr_name] = @attr.name
        coder[:subtype] = @subtype
      end

      def init_with(coder)
        initialize(
          coder[:class_name].constantize.enumerized_attributes[coder[:attr_name]],
          coder[:subtype]
        )
      end
    end
  end
end
