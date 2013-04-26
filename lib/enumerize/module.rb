module Enumerize
  class Module < ::Module
    attr_reader :_class_methods

    def initialize
      super

      @_class_methods   = ::Module.new
      @_dependents      = []
      @_dependent_evals = []
    end

    def included(klass)
      klass.extend _class_methods

      @_dependent_evals.each do |block|
        klass.instance_eval(&block)
      end

      @_dependents << klass
    end

    def dependent_eval(&block)
      @_dependents.each do |klass|
        klass.instance_eval(&block)
      end

      @_dependent_evals << block
    end
  end
end
