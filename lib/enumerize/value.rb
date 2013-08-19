require 'i18n'

module Enumerize
  class Value < String
    include Predicatable

    def initialize(attr, name, value=nil)
      @attr  = attr
      @value = value || name.to_s

      super(name.to_s)
    end

    def value
      @value
    end

    def text
      I18n.t(i18n_keys[0], :default => i18n_keys[1..-1])
    end

    private

    def define_query_method(value)
      singleton_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{value}?
          #{value == self}
        end
      RUBY
    end

    def i18n_keys
      @i18n_keys ||= begin
        i18n_keys = []
        i18n_keys << i18n_scope(i18n_suffix)
        i18n_keys << i18n_scope
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
