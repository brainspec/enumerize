module Enumerize
  module Hooks
    module SimpleForm
      def initialize(builder, attribute_name, column, input_type, options = {})
        @builder = builder
        if object.class.send(attribute_name).instance_of?(Enumerize::Attribute)
          options.merge!(:collection => object.class.send(attribute_name).options)
        end

        super
      end
    end
  end
end

::SimpleForm::Inputs::Base.send :include, Enumerize::Hooks::SimpleForm
