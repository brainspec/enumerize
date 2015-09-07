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
    end
  end
end
