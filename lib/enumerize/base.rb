require 'active_support/concern'

module Enumerize
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def enumerize(name, options={})
        attr = Attribute.new(self, name, options)
        enumerized_attributes << attr

        unless methods.include?(attr.name)
          singleton_class.class_eval do
            define_method(attr.name) { attr }
          end
        end

        mod = Module.new

        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def initialize(*, &_)
            @_enumerized_values_for_validation = {}
            super
            self.#{attr.name} = self.class.enumerized_attributes[:#{attr.name}].default_value if #{attr.name}.nil?
          end
        RUBY

        _define_enumerize_attribute(mod, attr)

        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{attr.name}_text
            #{attr.name} && #{attr.name}.text
          end
        RUBY

        include mod

        if respond_to?(:validates)
          validates name, :inclusion => {:in => enumerized_attributes[name].values.map(&:to_s), :allow_nil => true}
        end
      end

      def enumerized_attributes
        @enumerized_attributes ||= AttributeMap.new
      end

      def inherited(subclass)
        enumerized_attributes.add_dependant subclass.enumerized_attributes
        super
      end

      private

      def _define_enumerize_attribute(mod, attr)
        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{attr.name}
            if respond_to?(:read_attribute, true)
              self.class.enumerized_attributes[:#{attr.name}].find_value(read_attribute(:#{attr.name}))
            else
              if defined?(@#{attr.name})
                self.class.enumerized_attributes[:#{attr.name}].find_value(@#{attr.name})
              else
                @#{attr.name} = nil
              end
            end
          end

          def #{attr.name}=(new_value)
            @_enumerized_values_for_validation[:#{attr.name}] = new_value.to_s

            if respond_to?(:write_attribute, true)
              write_attribute :#{attr.name}, self.class.enumerized_attributes[:#{attr.name}].find_value(new_value).to_s
            else
              @#{attr.name} = self.class.enumerized_attributes[:#{attr.name}].find_value(new_value).to_s
            end
          end
        RUBY
      end
    end

    def read_attribute_for_validation(key)
      if self.class.enumerized_attributes[key].instance_of? Enumerize::Attribute
        @_enumerized_values_for_validation[key]
      else
        super
      end
    end
  end
end
