require 'active_support/concern'

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
          end
        end
      end
    end
  end
end
