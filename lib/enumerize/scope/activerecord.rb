# frozen_string_literal: true

module Enumerize
  module Scope
    module ActiveRecord
      def enumerize(name, options={})
        super

        _enumerize_module.dependent_eval do
          if self < ::ActiveRecord::Base
            if options[:scope]
              _define_activerecord_scope_methods!(name, options)
            end
          end
        end
      end

      private

      def _define_activerecord_scope_methods!(name, options)
        return _define_activerecord_shallow_scopes!(name) if options[:scope] == :shallow

        scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]

        define_singleton_method scope_name do |*values|
          values = enumerized_attributes[name].find_values(*values).map(&:value)
          values = values.first if values.size == 1

          where(name => values)
        end

        if options[:scope] == true
          define_singleton_method "without_#{name}" do |*values|
            values = enumerized_attributes[name].find_values(*values).map(&:value)
            where(arel_table[name].not_in(values))
          end
        end
      end

      def _define_activerecord_shallow_scopes!(attribute_name)
        enumerized_attributes[attribute_name].each_value do |value_obj|
          define_singleton_method(value_obj) do
            where(attribute_name => value_obj.value)
          end

          define_singleton_method("not_#{value_obj}") do
            where.not(attribute_name => value_obj.value)
          end
        end
      end
    end
  end
end
