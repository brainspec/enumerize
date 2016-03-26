require 'active_support/concern'

module Enumerize
  module Hooks
    module UniquenessValidator

      def validate_each(record, name, value)
        if record.class.respond_to?(:enumerized_attributes) && (attr = record.class.enumerized_attributes[name])
          value = attr.find_value(value).try(:value)
        end

        super(record, name, value)
      end
    end
  end
end

::ActiveRecord::Validations::UniquenessValidator.send :prepend, Enumerize::Hooks::UniquenessValidator
