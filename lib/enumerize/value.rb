require 'i18n'

module Enumerize
  class Value < String
    def initialize(attr, value)
      @attr = attr

      super(value.to_s)
    end

    def text
      I18n.t(i18n_keys.shift, :default => i18n_keys)
    end

    def method_missing(method, *args)
      value = method.to_s.gsub(/\?\Z/, '')
      super unless @attr.values.include?(value)
      raise ArgumentError if args.any?
      value == self
    end

    private

    def i18n_keys
      @i18n_keys ||= begin
        i18n_keys = []
        i18n_keys << i18n_scope
        i18n_keys << i18n_scope(i18n_suffix)
        i18n_keys << self.humanize # humanize value if there are no translations
      end
    end

    def i18n_scope(suffix = nil)
      :"enumerize.#{suffix}#{@attr.name}.#{self}"
    end

    def i18n_suffix
      "#{@attr.i18n_suffix}." if @attr.i18n_suffix
    end
  end
end
