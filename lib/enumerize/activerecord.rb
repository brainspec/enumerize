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
              where(name => values.map { |value| enumerized_attributes[name].find_value(value).value })
            }
          end
        end
      end
    end
  end
end
