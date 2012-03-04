module Enumerize
  module Hooks
    module FormtasticFormBuilderExtension
      def input(method, options={})
        klass = object.class
        if klass.respond_to?(method) && klass.send(method).instance_of?(Enumerize::Attribute)
          options[:collection] ||= object.class.send(method).options
        end

        super(method, options)
      end
    end
  end
end

::Formtastic::FormBuilder.send :include, Enumerize::Hooks::FormtasticFormBuilderExtension
