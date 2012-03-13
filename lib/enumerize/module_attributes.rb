module Enumerize
  module ModuleAttributes
    def included(base)
      base.send :include, Enumerize
      base.send :include, _enumerize_module
      base.extend _enumerize_module._class_methods
      enumerized_attributes.add_dependant base.enumerized_attributes
      super
    end
  end
end
