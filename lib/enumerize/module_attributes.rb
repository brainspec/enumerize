module Enumerize
  module ModuleAttributes
    def included(base)
      base.extend Enumerize
      base.send :include, _enumerize_module
      enumerized_attributes.add_dependant base.enumerized_attributes
      super
    end
  end
end
