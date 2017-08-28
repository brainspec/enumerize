module Sequel
  module Plugins
    module Enumerize
      module InstanceMethods
        def self.included(base)
          base.extend ::Enumerize
        end
      end
    end
  end
end
