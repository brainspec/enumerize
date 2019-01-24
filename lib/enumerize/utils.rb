# frozen_string_literal: true

module Enumerize
  module Utils
    class << self
      def call_if_callable(value, param = nil)
        return value unless value.respond_to?(:call)
        value.arity == 0 ? value.call : value.call(param)
      end
    end
  end
end
