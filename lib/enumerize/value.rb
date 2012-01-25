require 'yaml'
require 'i18n'

module Enumerize
  class Value < String
    def initialize(attr, value)
      singleton_class.class_eval do
        define_method(:attr) { attr }
      end

      super(value.to_s)
      freeze
    end

    def text
      i18n_keys = ['']
      i18n_keys.unshift "#{attr.i18n_suffix}." if attr.i18n_suffix
      i18n_keys.map! { |k| :"enumerize.#{k}#{attr.name}.#{self}" }
      I18n.t(i18n_keys.shift, :default => i18n_keys)
    end

    if YAML::ENGINE.yamler == 'syck'
      def to_yaml(opts={})
        to_s.to_yaml(opts)
      end
    end
  end
end
