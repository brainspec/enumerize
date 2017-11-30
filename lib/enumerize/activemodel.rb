module Enumerize
  module ActiveModelAttributesSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if self.included_modules.include? ::ActiveModel::Attributes
          include InstanceMethods

          attribute name, Enumerize::ActiveModelAttributesSupport::Type.new(enumerized_attributes[name])
        end
      end
    end

    module InstanceMethods
      # https://github.com/brainspec/enumerize/issues/74
      def write_attribute(attr_name, value, *options)
        if self.class.enumerized_attributes[attr_name]
          _enumerized_values_for_validation[attr_name.to_s] = value
        end

        super
      end
    end

    class Type < ActiveModel::Type::Value
      def type
        :enumerize
      end

      def initialize(attr)
        @attr = attr
      end

      def serialize(value)
        v = @attr.find_value(value)
        v && v.value
      end

      def deserialize(value)
        @attr.find_value(value)
      end
    end
  end
end
