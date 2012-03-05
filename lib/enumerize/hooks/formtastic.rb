module Enumerize
  module Hooks
    module FormtasticFormBuilderExtension
      def input(method, options={})
        klass = object.class
        if klass.respond_to?(:enumerized_attributes) && (attr = klass.enumerized_attributes[method])
          options[:collection] ||= attr.options
        end

        super(method, options)
      end
    end
  end
end

::Formtastic::FormBuilder.send :include, Enumerize::Hooks::FormtasticFormBuilderExtension
