# frozen_string_literal: true

require 'i18n'
require 'active_support/inflector'

module Enumerize
  class Value < String
    include Predicatable

    attr_reader :value

    def initialize(attr, name, value=nil)
      @attr  = attr
      @value = value.nil? ? name.to_s : value

      super(name.to_s)
    end

    def text
      keys = @attr.i18n_keys(self) { build_i18n_keys }
      I18n.t(keys[0], :default => keys[1..-1])
    end

    def ==(other)
      super(other.to_s) || value == other
    end

    def encode_with(coder)
      coder.represent_object(self.class.superclass, @value)
    end

    def as_json(*)
      to_s
    end

    private

    # Composes the ordered i18n lookup keys for this value. Invoked by the
    # attribute only on a cache miss (see Attribute#i18n_keys), so values whose
    # +text+ is never rendered never build or retain their keys.
    def build_i18n_keys
      keys = @attr.i18n_scopes.map do |s|
        scope = Utils.call_if_callable(s, @value)

        :"#{scope}.#{self}"
      end
      keys << :"enumerize.defaults.#{@attr.name}.#{self}"
      keys << :"enumerize.#{@attr.name}.#{self}"
      keys << ActiveSupport::Inflector.humanize(ActiveSupport::Inflector.underscore(self)) # humanize value if there are no translations
      keys
    end

    def predicate_call(value)
      value == self
    end
  end
end
