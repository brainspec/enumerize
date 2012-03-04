require 'active_support/concern'

module Enumerize
  module Hooks
    module SimpleFormBuilderExtension
      extend ActiveSupport::Concern

      included do
        alias_method_chain :input, :enumerize
      end

      def input_with_enumerize(attribute_name, options={}, &block)
        klass = object.class
        if klass.respond_to?(:enumerized_attributes) && klass.enumerized_attributes[attribute_name].instance_of?(Enumerize::Attribute)
          options[:collection] ||= klass.send(attribute_name).options
        end

        input_without_enumerize(attribute_name, options, &block)
      end
    end
  end
end

::SimpleForm::FormBuilder.send :include, Enumerize::Hooks::SimpleFormBuilderExtension
