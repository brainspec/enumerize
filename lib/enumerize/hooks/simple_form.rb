require 'active_support/concern'

module Enumerize
  module Hooks
    module SimpleFormInputBaseExtension
      def initialize(builder, attribute_name, column, input_type, options = {})
        @builder = builder
        if object.class.send(attribute_name).instance_of?(Enumerize::Attribute)
          options.merge!(:collection => object.class.send(attribute_name).options)
        end

        super
      end
    end

    module SimpleFormBuilderExtension
      extend ActiveSupport::Concern

      included do
        alias_method_chain :input, :enumerize
      end

      def input_with_enumerize(attribute_name, options={}, &block)
        if object.class.send(attribute_name).instance_of?(Enumerize::Attribute)
          options[:as] ||= :select
        end

        input_without_enumerize(attribute_name, options, &block)
      end
    end
  end
end

::SimpleForm::Inputs::Base.send :include, Enumerize::Hooks::SimpleFormInputBaseExtension
::SimpleForm::FormBuilder.send :include, Enumerize::Hooks::SimpleFormBuilderExtension
