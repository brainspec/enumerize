module Enumerize
  class Set
    include Enumerable
    include Predicatable

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

    delegate :each, :empty?, :size, to: :values

    def to_ary
      @values.to_a
    end

    delegate :join, to: :to_ary

    def ==(other)
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

    private

    def define_query_method(value)
      singleton_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{value}?
          include?("#{value}")
        end
      RUBY
    end

    def mutate!
      @values = @obj.public_send("#{@attr.name}=", @values).values
    end
  end
end
