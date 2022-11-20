# frozen_string_literal: true

module Enumerize
  module MongoidSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if self < ::Mongoid::Document
          include InstanceMethods

          after_initialize :_set_default_value_for_enumerized_attributes
        end
      end
    end

    module InstanceMethods
      def reload
        reloaded = super

        reloaded.class.enumerized_attributes.each do |attr|
          reloaded.send("#{attr.name}=", reloaded[attr.name])
        end

        reloaded
      end

      private

      def _set_default_value_for_enumerized_attribute(attr)
        super
      rescue Mongoid::Errors::AttributeNotLoaded
      end
    end
  end
end
