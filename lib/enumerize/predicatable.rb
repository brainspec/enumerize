module Enumerize
  module Predicatable
    def method_missing(method, *args, &block)
      if boolean_method?(method)
        define_query_methods
        send(method, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method, include_private=false)
      boolean_method?(method)
    end

    private

    def define_query_methods
      @attr.values.each do |value|
        unless singleton_methods.include?(:"#{value}?")
          define_query_method(value)
        end
      end
    end

    def boolean_method?(method)
      method[-1] == '?' && @attr.values.include?(method[0..-2])
    end
  end
end
