require 'active_support/concern'

module Enumerize
  module ActiveRecord
    def enumerize_scope(*names)
      options = names.last.is_a?(Hash) ? names.pop : {}
      prefix = options[:prefix] || 'with'
      names.each do |name|
        scope "#{prefix}_#{name}", ->(*values) {
          where(name => values.map { |value| enumerized_attributes[name].find_value(value).value })
        }
      end
    end
  end
end
