# frozen_string_literal: true

require 'i18n'

module Enumerize
  class Value < String
    include Predicatable

    attr_reader :value

    def initialize(attr, name, value=nil)
      @attr  = attr
      @value = value.nil? ? name.to_s : value

      super(name.to_s)

      @i18n_keys = @attr.i18n_scopes.map { |s| :"#{s}.#{self}" }
      @i18n_keys << :"enumerize.defaults.#{@attr.name}.#{self}"
      @i18n_keys << :"enumerize.#{@attr.name}.#{self}"
      @i18n_keys << self.underscore.humanize # humanize value if there are no translations
      @i18n_keys
    end

    def text
      I18n.t(@i18n_keys[0], :default => @i18n_keys[1..-1])
    end

    def ==(other)
      super(other.to_s) || value == other
    end

    def encode_with(coder)
      coder.represent_object(self.class.superclass, @value)
    end

    private

    def predicate_call(value)
      value == self
    end
  end
end
