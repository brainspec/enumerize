module Enumerize
  module ModuleAttributes
    def included(base)
      base.send :include, Enumerize
      enumerized_attributes.add_dependant base.enumerized_attributes
      super
    end
  end
end
