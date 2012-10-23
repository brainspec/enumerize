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
        attr  = klass.enumerized_attributes[attribute_name]

        if klass.respond_to?(:enumerized_attributes) && attr
          options[:collection] ||= attr.options
        end

        if attr.kind_of?(Enumerize::Multiple) && options[:as] != :check_boxes
          options[:input_html] = options.fetch(:input_html, {}).merge(:multiple => true)
        end

        input_without_enumerize(attribute_name, options, &block)
      end
    end
  end
end

::SimpleForm::FormBuilder.send :include, Enumerize::Hooks::SimpleFormBuilderExtension
