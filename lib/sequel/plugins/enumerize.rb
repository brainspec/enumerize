module Sequel
  module Plugins
    module Enumerize
      # Depend on the def_dataset_method plugin
      def self.apply(model)
        model.plugin(:def_dataset_method) unless model.respond_to?(:def_dataset_method)
      end

      module InstanceMethods
        def self.included(base)
          base.extend ::Enumerize
        end
      end
    end
  end
end
