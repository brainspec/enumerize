require 'active_support/concern'

module Enumerize
  module ActiveRecord
    def enumerize(name, options={})
      super

      if options[:scope]
        scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]
        scope scope_name, ->(*values) {
          where(name => values.map { |value| enumerized_attributes[name].find_value(value).value })
        }
      end
    end
  end
end
