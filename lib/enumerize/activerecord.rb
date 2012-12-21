require 'active_support/concern'

module Enumerize
  module ActiveRecord
    def enumerize(name, options={})
      super

      scope "with_#{name}", ->(*values) {
        where(name => values.map { |value| enumerized_attributes[name].find_value(value).value })
      }
    end
  end
end
