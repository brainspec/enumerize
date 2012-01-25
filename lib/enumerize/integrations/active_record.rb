require 'active_support/concern'

module Enumerize
  module Integrations
    module ActiveRecord
      extend ActiveSupport::Concern

      module ClassMethods
        def enumerize(*args, &block)
          attr = Attribute.new(self, *args)
          singleton_class.class_eval do
            define_method(attr.name) { attr }
          end

          mod = Module.new

          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr.name}
              super
            end

            def #{attr.name}_text
              #{attr.name} && #{attr.name}.text
            end

            def #{attr.name}=(new_value)
              super self.class.#{attr.name}.find_value(new_value)
            end
          RUBY

          include mod
        end
      end
    end
  end
end
