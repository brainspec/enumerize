require 'active_support/concern'

module Enumerize
  module Integrations
    module ActiveRecord
      extend ActiveSupport::Concern

      include Integrations::Basic

      module ClassMethods
        private

        def _define_enumerize_attribute(mod, attr)
          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr.name}
              self.class.#{attr.name}.find_value(super)
            end

            def #{attr.name}=(new_value)
              super self.class.#{attr.name}.find_value(new_value).to_s
            end
          RUBY
        end
      end
    end
  end
end
