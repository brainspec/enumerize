module Enumerize
  module MongoidSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if self < ::Mongoid::Document
          after_initialize :_set_default_value_for_enumerized_attributes
        end
      end
    end
  end
end
