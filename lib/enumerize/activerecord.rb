module Enumerize
  module ActiveRecordSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if self < ::ActiveRecord::Base
          include InstanceMethods

          # Since Rails use `allocate` method on models and initializes them with `init_with` method.
          # This way `initialize` method is not being called, but `after_initialize` callback always gets triggered.
          after_initialize :_set_default_value_for_enumerized_attributes

          # https://github.com/brainspec/enumerize/issues/111
          require 'enumerize/hooks/uniqueness'
        end
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
    end

    def update_all(updates)
      if updates.is_a?(Hash)
        enumerized_attributes.each do |attr|
          next if updates[attr.name].blank? || attr.kind_of?(Enumerize::Multiple)
          updates[attr.name] = attr.find_value(updates[attr.name]).value
        end
      end

      super(updates)
    end
  end
end
