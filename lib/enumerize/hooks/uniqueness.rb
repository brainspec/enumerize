require 'active_support/concern'

module Enumerize
  module Hooks
    module UniquenessValidator
      extend ActiveSupport::Concern

      included do
        alias_method_chain :validate_each, :enumerize
      end

      def validate_each_with_enumerize(record, name, value)
        if record.class.respond_to?(:enumerized_attributes) && (attr = record.class.enumerized_attributes[name])
          value = attr.find_value(value).try(:value)
        end

        validate_each_without_enumerize(record, name, value)
      end
    end
  end
end

::ActiveRecord::Validations::UniquenessValidator.send :include, Enumerize::Hooks::UniquenessValidator
