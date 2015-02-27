module Enumerize
  module Predicatable
    def respond_to_missing?(method, include_private=false)
      predicate_method?(method) || super
    end

    private

    def method_missing(method, *args, &block)
      if predicate_method?(method)
        predicate_call(method[0..-2], *args, &block)
      else
        super
      end
    end

    def predicate_method?(method)
      method[-1] == '?' && @attr.values.include?(method[0..-2])
    end
  end
end
