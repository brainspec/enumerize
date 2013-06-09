module Enumerize
  class AttributeMap
    attr_reader :attributes

    def initialize
      @attributes = {}
      @dependants = []
    end

    def [](name)
      @attributes[name.to_s]
    end

    def <<(attr)
      @attributes[attr.name.to_s] = attr
      @dependants.each do |dependant|
        dependant << attr
      end
    end

    def each
      @attributes.each_pair do |_name, attr|
        yield attr
      end
    end

    def empty?
      @attributes.empty?
    end

    def add_dependant(dependant)
      @dependants << dependant
      each do |attr|
        dependant << attr
      end
    end
  end
end
