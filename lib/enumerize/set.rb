require 'active_support/core_ext/module/delegation'

module Enumerize
  class Set
    include Enumerable
    include Predicatable

    attr_reader :values

    def initialize(obj, attr, values)
      @obj    = obj
      @attr   = attr
      @values = []

      if values.respond_to?(:each)
        values.each do |input|
          value = @attr.find_value(input)

          if value && !@values.include?(value)
            @values << value
          end
        end
      end
    end

    def <<(value)
      @values << value
      mutate!
    end

    alias_method :push, :<<

    delegate :each, :empty?, :size, to: :values

    def to_ary
      @values.to_a
    end

    def texts
      @values.map(&:text)
    end

    delegate :join, to: :to_ary

    def ==(other)
      return false unless other.respond_to?(:each)
      other.size == size && other.all? { |v| @values.include?(@attr.find_value(v)) }
    end

    alias_method :eql?, :==

    def include?(value)
      @values.include?(@attr.find_value(value))
    end

    def delete(value)
      @values.delete(@attr.find_value(value))
      mutate!
    end

    def inspect
      "#<Enumerize::Set {#{join(', ')}}>"
    end

    def encode_with(coder)
      coder.represent_object(Array, @values)
    end

    private

    def predicate_call(value)
      include?(value)
    end

    def mutate!
      @values = @obj.public_send("#{@attr.name}=", @values).values
    end
  end
end
