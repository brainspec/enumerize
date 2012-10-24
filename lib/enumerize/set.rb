module Enumerize
  class Set
    include Enumerable

    attr_reader :values

    def initialize(obj, attr, values)
      @obj    = obj
      @attr   = attr
      @values = ::Set.new

      if values.respond_to?(:each)
        values.each do |input|
          value = @attr.find_value(input)
          @values << value if value
        end
      end
    end

    def <<(value)
      @values << value
      mutate!
    end

    alias_method :push, :<<

    delegate :each, :empty?, to: :values

    alias_method :to_ary, :values

    def ==(other)
      @values.to_a == other.map { |v| @attr.find_value(v) }
    end

    alias_method :eql?, :==

    def include?(value)
      @values.include?(@attr.find_value(value))
    end

    def delete(value)
      @values.delete(@attr.find_value(value))
      mutate!
    end

    private

    def mutate!
      @values = @obj.public_send("#{@attr.name}=", @values).values
    end
  end
end
