require 'active_support/concern'

module Enumerize
  module Hooks
    module SimpleFormBuilderExtension
      extend ActiveSupport::Concern

      included do
        alias_method_chain :input, :enumerize
        alias_method_chain :input_field, :enumerize
      end

      def input_with_enumerize(attribute_name, options={}, &block)
        add_input_options_for_enumerized_attribute(attribute_name, options)
        input_without_enumerize(attribute_name, options, &block)
      end

      def input_field_with_enumerize(attribute_name, options={})
        add_input_options_for_enumerized_attribute(attribute_name, options)
        input_field_without_enumerize(attribute_name, options)
      end

      private

      def add_input_options_for_enumerized_attribute(attribute_name, options)
        klass = object.class

        if klass.respond_to?(:enumerized_attributes) && (attr = klass.enumerized_attributes[attribute_name])
          options[:collection] ||= attr.options

          if attr.kind_of?(Enumerize::Multiple) && options[:as] != :check_boxes
            options[:input_html] = options.fetch(:input_html, {}).merge(:multiple => true)
          end
        end
      end
    end
  end
end

::SimpleForm::FormBuilder.send :include, Enumerize::Hooks::SimpleFormBuilderExtension
