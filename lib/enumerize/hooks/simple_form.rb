require 'active_support/concern'

module Enumerize
  module Hooks
    module SimpleFormBuilderExtension

      def input(attribute_name, options={}, &block)
        add_input_options_for_enumerized_attribute(attribute_name, options)
        super(attribute_name, options, &block)
      end

      def input_field(attribute_name, options={})
        add_input_options_for_enumerized_attribute(attribute_name, options)
        super(attribute_name, options)
      end

      private

      def add_input_options_for_enumerized_attribute(attribute_name, options)
        enumerized_object = convert_to_model(object)
        klass = enumerized_object.class

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

::SimpleForm::FormBuilder.send :prepend, Enumerize::Hooks::SimpleFormBuilderExtension
