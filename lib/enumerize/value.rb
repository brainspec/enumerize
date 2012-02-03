require 'i18n'

module Enumerize
  class Value < String
    def initialize(attr, value)
      @attr = attr

      super(value.to_s)
      freeze
    end

    def text
      i18n_keys = ['']
      i18n_keys.unshift "#{@attr.i18n_suffix}." if @attr.i18n_suffix
      i18n_keys.map! { |k| :"enumerize.#{k}#{@attr.name}.#{self}" }
      I18n.t(i18n_keys.shift, :default => i18n_keys)
    end

    def method_missing(method, *args)
      value = method.to_s.gsub(/\?\Z/, '')
      super unless @attr.values.include?(value)
      raise ArgumentError if args.any?
      value == self
    end
  end
end
