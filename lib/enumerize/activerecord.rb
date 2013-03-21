require 'active_support/concern'

module Enumerize
  module ActiveRecord
    def enumerize(name, options={})
      super

      if options[:scope]
        _enumerize_module.dependent_eval do
          if defined?(::ActiveRecord::Base) && self < ::ActiveRecord::Base
            scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]
            scope scope_name, ->(*values) {
              values = values.map { |value| enumerized_attributes[name].find_value(value).value }
              values = values.first if values.size == 1

              where(name => values)
            }
          end
        end
      end
    end
  end
end
