module Enumerize
  module ActiveRecord
    def enumerize(name, options={})
      super

      if options[:scope]
        _enumerize_module.dependent_eval do
          if defined?(::ActiveRecord::Base) && self < ::ActiveRecord::Base
            _define_scope_methods!(name, options)

            class_eval do
              # https://github.com/brainspec/enumerize/issues/74
              def write_attribute(attr_name, value)
                _enumerized_values_for_validation[attr_name] = value

                super
              end

              # Since Rails use `allocate` method on models and initializes them with `init_with` method.
              # This way `initialize` method is not being called, but `after_initialize` callback always gets triggered.
              after_initialize :_set_default_value_for_enumerized_attributes
            end
          end
        end
      end
    end

    private

    def _define_scope_methods!(name, options)
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
    end
  end
end
