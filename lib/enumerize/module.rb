module Enumerize
  class Module < ::Module
    attr_reader :_class_methods

    def initialize
      super

      @_class_methods = ::Module.new
    end

    def included(klass)
      klass.extend _class_methods
    end
  end
end
