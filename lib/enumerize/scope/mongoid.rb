# frozen_string_literal: true

module Enumerize
  module Scope
    module Mongoid
      def enumerize(name, options={})
        super

        _enumerize_module.dependent_eval do
          if self < ::Mongoid::Document
            if options[:scope]
              _define_mongoid_scope_methods!(name, options)
            end
          end
        end
      end

      private

      def _define_mongoid_scope_methods!(name, options)
        return _define_mongoid_shallow_scopes!(name) if options[:scope] == :shallow
        scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]

        define_singleton_method scope_name do |*values|
          values = enumerized_attributes[name].find_values(*values).map(&:value)
          self.in(name => values)
        end

        if options[:scope] == true
          define_singleton_method "without_#{name}" do |*values|
            values = enumerized_attributes[name].find_values(*values).map(&:value)
            not_in(name => values)
          end
        end
      end

      def _define_mongoid_shallow_scopes!(attribute_name)
        enumerized_attributes[attribute_name].each_value do |value_obj|
          define_singleton_method(value_obj) do
            self.in(attribute_name => value_obj.value)
          end

          define_singleton_method("not_#{value_obj}") do
            self.not_in(attribute_name => value_obj.value)
          end
        end
      end
    end
  end
end
