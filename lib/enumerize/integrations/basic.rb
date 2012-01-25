require 'active_support/concern'

module Enumerize
  module Integrations
    module Basic
      extend ActiveSupport::Concern

      module ClassMethods
        def enumerize(*args, &block)
          attr = Attribute.new(self, *args)
          singleton_class.class_eval do
            define_method(attr.name) { attr }
          end

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr.name}
              if defined?(@#{attr.name})
                @#{attr.name}
              else
                @#{attr.name} = self.class.#{attr.name}.default_value
              end
            end

            def #{attr.name}_text
              #{attr.name}.text
            end

            def #{attr.name}=(new_value)
              @#{attr.name} = self.class.#{attr.name}.find_value(new_value)
            end
          RUBY
        end
      end
    end
  end
end
