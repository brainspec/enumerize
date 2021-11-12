# frozen_string_literal: true

module Enumerize
  module Scope
    module Sequel
      def enumerize(name, options={})
        super

        _enumerize_module.dependent_eval do
          if defined?(::Sequel::Model) && self < ::Sequel::Model
            if options[:scope]
              _define_sequel_scope_methods!(name, options)
            end

            require 'enumerize/hooks/sequel_dataset'
          end
        end
      end

      private

      def _define_sequel_scope_methods!(name, options)
        return _define_sequel_shallow_scopes!(name) if options[:scope] == :shallow

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

      def _define_sequel_shallow_scopes!(attribute_name)
        enumerized_attributes[attribute_name].each_value do |value_obj|
          def_dataset_method(value_obj) do
            where(attribute_name => value_obj.value.to_s)
          end

          def_dataset_method("not_#{value_obj}") do
            exclude(attribute_name => value_obj.value.to_s)
          end
        end
      end
    end
  end
end
