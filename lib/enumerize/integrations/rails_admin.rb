module Enumerize
  module Integrations
    module RailsAdmin

      def enumerize(name, options={})
        super

        _enumerize_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}_enum
            self.class.enumerized_attributes[:#{name}].options
          end
        RUBY
      end
    end
  end
end
