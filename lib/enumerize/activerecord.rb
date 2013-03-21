require 'active_support/concern'

module Enumerize
  module ActiveRecord
    def enumerize(name, options={})
      super

      if options[:scope]
        _enumerize_module.dependent_eval do
          if defined?(::ActiveRecord::Base) && self < ::ActiveRecord::Base
            if options[:scope] == true
              scope "with_#{name}", ->(*values) {
                where(name => values.map { |value| enumerized_attributes[name].find_value(value).value })
              }

              scope "without_#{name}", ->(*values) {
                where("#{name} NOT IN (?)", values.map { |value| enumerized_attributes[name].find_value(value).value })
              }
            else
              scope options[:scope], ->(*values) {
                where(name => values.map { |value| enumerized_attributes[name].find_value(value).value })
              }
            end
          end
        end
      end
    end
  end
end
