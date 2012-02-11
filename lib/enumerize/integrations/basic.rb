require 'active_support/concern'

module Enumerize
  module Integrations
    module Basic
      extend ActiveSupport::Concern

      module ClassMethods
        def enumerize(*args, &block)
          attr = Attribute.new(self, *args, &block)
          singleton_class.class_eval do
            define_method(attr.name) { attr }
          end

          mod = Module.new

          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def initialize(*, &_)
              super
              self.#{attr.name} = self.class.#{attr.name}.default_value if #{attr.name}.nil?
            end
          RUBY

          _define_enumerize_attribute(mod, attr)

          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr.name}_text
              #{attr.name} && #{attr.name}.text
            end
          RUBY

          include mod
        end

        private

        def _define_enumerize_attribute(mod, attr)
          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr.name}
              if respond_to?(:read_attribute, true)
                self.class.#{attr.name}.find_value(read_attribute(:#{attr.name}))
              else
                if defined?(@#{attr.name})
                  self.class.#{attr.name}.find_value(@#{attr.name})
                else
                  @#{attr.name} = nil
                end
              end
            end

            def #{attr.name}=(new_value)
              if respond_to?(:write_attribute, true)
                write_attribute :#{attr.name}, self.class.#{attr.name}.find_value(new_value).to_s
              else
                @#{attr.name} = self.class.#{attr.name}.find_value(new_value).to_s
              end
            end
          RUBY
        end
      end
    end
  end
end
