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

            if options[:has_many_scope]
              @enums_with_association_scope ||= {}
              @enums_with_association_scope[name] = options[:has_many_scope]

              _define_activerecord_children_scope_methods!(name, options)
            end
          end
        end
      end

      def has_many(name, scope = nil, options = {}, &extension)
        if defined?(@enums_with_association_scope) && @enums_with_association_scope.any?
          @enums_with_association_scope.each do |field, scope_value|
            parent_association_name = table_name.singularize.to_sym
            klass = name.to_s.classify.constantize
            _define_activerecord_child_scope_methods(field, parent_association_name, klass, scope_value)
          end
        end

        super
      end

      private

      def _define_activerecord_scope_methods!(name, options)
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

      def _define_activerecord_children_scope_methods!(field, options)
        parent_association_name = table_name.singularize.to_sym
        reflect_on_all_associations(:has_many).each do |association|
          klass = association.class_name.constantize
          _define_activerecord_child_scope_methods(field, parent_association_name, klass, options[:has_many_scope])
        end
      end

      def _define_activerecord_child_scope_methods(field, parent_association_name, klass, scope_value)
        parent_klass = self

        scope_name =
          if scope_value == true
            "with_#{parent_association_name}_#{field}"
          else
            "#{parent_association_name}_options[:scope]"
          end

        klass.define_singleton_method scope_name do |*values|
          values = parent_klass.enumerized_attributes[field].find_values(*values).map(&:value)
          values = values.first if values.size == 1
          joins(parent_association_name).where(parent_klass.table_name.to_sym => { field => values })
        end

        if scope_value == true
          klass.define_singleton_method "without_#{parent_association_name}_#{field}" do |*values|
            values = parent_klass.enumerized_attributes[field].find_values(*values).map(&:value)
            joins(parent_association_name).where(parent_klass.arel_table[field].not_in(values))
          end
        end
      end

    end
  end
end
