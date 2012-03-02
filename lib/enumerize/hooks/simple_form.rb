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
        if klass.respond_to?(attribute_name) && klass.send(attribute_name).instance_of?(Enumerize::Attribute)
          options[:collection] ||= object.class.send(attribute_name).options
          options[:as]         ||= :select
        end

        input_without_enumerize(attribute_name, options, &block)
      end
    end
  end
end

::SimpleForm::FormBuilder.send :include, Enumerize::Hooks::SimpleFormBuilderExtension
