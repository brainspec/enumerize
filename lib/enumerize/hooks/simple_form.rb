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

        if klass.respond_to?(:enumerized_attributes) && (attr = klass.enumerized_attributes[attribute_name])
          options[:collection] ||= attr.options

          if attr.kind_of?(Enumerize::Multiple) && options[:as] != :check_boxes
            options[:input_html] = options.fetch(:input_html, {}).merge(:multiple => true)
          end
        end

        input_without_enumerize(attribute_name, options, &block)
      end
    end
  end
end

::SimpleForm::FormBuilder.send :include, Enumerize::Hooks::SimpleFormBuilderExtension
