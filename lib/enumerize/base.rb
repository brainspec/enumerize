module Enumerize
  module Base
    def self.included(base)
      base.extend ClassMethods

      if base.respond_to?(:validate)
        base.validate :_validate_enumerized_attributes
      end

      class << base
        if (method_defined?(:inherited) || private_method_defined?(:inherited)) && !private_method_defined?(:inherited_without_enumerized)
          alias_method :inherited_without_enumerized, :inherited
          private :inherited_without_enumerized
        end

        alias_method :inherited, :inherited_with_enumerized
      end
    end

    module ClassMethods
      def enumerize(name, options={})
        attr = Attribute.new(self, name, options)
        enumerized_attributes << attr

        unless methods.include?(attr.name)
          _enumerize_module._class_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr.name}
              enumerized_attributes[:#{attr.name}]
            end
          RUBY
        end

        attr.define_methods!(_enumerize_module)
      end

      def enumerized_attributes
        @enumerized_attributes ||= AttributeMap.new
      end

      def inherited_with_enumerized(subclass)
        enumerized_attributes.add_dependant subclass.enumerized_attributes
        if respond_to?(:inherited_without_enumerized, true)
          inherited_without_enumerized subclass
        end
      end

      private

      def _enumerize_module
        @_enumerize_module ||= begin
          mod = Module.new
          include mod
          mod
        end
      end
    end

    def initialize(*)
      super
      _set_default_value_for_enumerized_attributes
    end

    def read_attribute_for_validation(key)
      key = key.to_s

      if _enumerized_values_for_validation.has_key?(key)
        _enumerized_values_for_validation[key]
      else
        super
      end
    end

    private

    def _enumerized_values_for_validation
      @_enumerized_values_for_validation ||= {}
    end

    def _validate_enumerized_attributes
      self.class.enumerized_attributes.each do |attr|
        value = read_attribute_for_validation(attr.name)
        next if value.blank?

        if attr.kind_of? Multiple
          errors.add attr.name unless value.respond_to?(:all?) && value.all? { |v| v.blank? || attr.find_value(v) }
        else
          errors.add attr.name, :inclusion unless attr.find_value(value)
        end
      end
    end

    def _set_default_value_for_enumerized_attributes
      self.class.enumerized_attributes.each do |attr|
        if respond_to?(attr.name)
          attr_value = public_send(attr.name)
        else
          next
        end

        value_for_validation = _enumerized_values_for_validation[attr.name.to_s]

        if (!attr_value || attr_value.empty?) && (!value_for_validation || value_for_validation.empty?)
          value = attr.default_value

          if value.respond_to?(:call)
            value = value.arity == 0 ? value.call : value.call(self)
          end

          public_send("#{attr.name}=", value)
        end
      end
    end
  end
end
