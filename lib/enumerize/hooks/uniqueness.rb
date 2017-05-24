require 'active_support/concern'

module Enumerize
  module Hooks
    module UniquenessValidator

      def validate_each(record, name, value)
        klass = record.to_model.class

        if klass.respond_to?(:enumerized_attributes) && (attr = klass.enumerized_attributes[name])
          value = attr.find_value(value).try(:value)
        end

        super(record, name, value)
      end
    end
  end
end

::ActiveRecord::Validations::UniquenessValidator.send :prepend, Enumerize::Hooks::UniquenessValidator
