module Enumerize
  module SequelSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if defined?(::Sequel::Model) && self < ::Sequel::Model
          if options[:scope]
            _define_sequel_scope_methods!(name, options)
          end

          include InstanceMethods
        end
      end
    end

    private

    def _define_sequel_scope_methods!(name, options)
      klass = self
      scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]

      def_dataset_method scope_name do |*values|
        values = values.map { |value| klass.enumerized_attributes[name].find_value(value).value }
        values = values.first if values.size == 1

        where(name => values)
      end

      if options[:scope] == true
        def_dataset_method "without_#{name}" do |*values|
          values = values.map { |value| klass.enumerized_attributes[name].find_value(value).value }
          exclude(name => values)
        end
      end
    end

    module InstanceMethods
      def validate
        super
        self.class.enumerized_attributes.each do |attr|
          value = read_attribute_for_validation(attr.name)
          next if value.blank?

          if attr.kind_of? Multiple
            errors.add attr.name, "is invalid" unless value.respond_to?(:all?) && value.all? { |v| v.blank? || attr.find_value(v) }
          else
            errors.add attr.name, "is not included in the list" unless attr.find_value(value)
          end
        end
      end

      def _set_default_value_for_enumerized_attributes
        _enumerized_values_for_validation.delete_if do |k, v|
          v.nil?
        end

        if defined?(Sequel::Plugins::Serialization::InstanceMethods)
          modules = self.class.ancestors
          plugin_idx = modules.index(Sequel::Plugins::Serialization::InstanceMethods)
          if plugin_idx && plugin_idx < modules.index(Enumerize::SequelSupport::InstanceMethods)
            abort "ERROR: You need to enable the Sequel serialization plugin before calling any enumerize methods on a model."
          end
          plugin_idx = modules.index(Sequel::Plugins::ValidationHelpers::InstanceMethods)
          if plugin_idx && plugin_idx < modules.index(Enumerize::SequelSupport::InstanceMethods)
            abort "ERROR: You need to enable the Sequel validation_helpers plugin before calling any enumerize methods on a model."
          end
        end

        super
      end

      def change_column_value(*)
        @_enumerize_bypass_attr_reader = true
        super
        @_enumerize_bypass_attr_reader = false
      end

      def validates_unique(*)
        @_enumerize_bypass_attr_reader = true
        super
        @_enumerize_bypass_attr_reader = false
      end
    end
  end
end
