module Enumerize
  module ActiveRecord
    def enumerize(name, options={})
      super

      if options[:scope]
        _enumerize_module.dependent_eval do
          if defined?(::ActiveRecord::Base) && self < ::ActiveRecord::Base
            scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]
            define_singleton_method scope_name do |*values|
              values = values.map { |value| enumerized_attributes[name].find_value(value).value }
              values = values.first if values.size == 1

              where(name => values)
            end

            if options[:scope] == true
              define_singleton_method "without_#{name}" do |*values|
                values = values.map { |value| enumerized_attributes[name].find_value(value).value }
                where(arel_table[name].not_in(values))
              end
            end

            # https://github.com/brainspec/enumerize/issues/74
            class_eval do
              def write_attribute(attr_name, value)
                _enumerized_values_for_validation[attr_name] = value

                super
              end
            end
          end
        end
      end
    end
  end
end
