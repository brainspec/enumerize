require 'active_support/concern'

module Enumerize
  module Hooks
    module FormtasticFormBuilderExtension

      def input(method, options={})
        klass = object.class

        if klass.respond_to?(:enumerized_attributes) && (attr = klass.enumerized_attributes[method])
          options[:collection] ||= attr.options

          if attr.kind_of?(Enumerize::Multiple) && options[:as] != :check_boxes
            options[:input_html] = options.fetch(:input_html, {}).merge(:multiple => true)
          end
        end

        super(method, options)
      end
    end
  end
end

::Formtastic::FormBuilder.send :prepend, Enumerize::Hooks::FormtasticFormBuilderExtension
