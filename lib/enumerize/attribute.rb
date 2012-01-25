module Enumerize
  class Attribute
    attr_reader :name, :values

    def initialize(klass, name, options={})
      raise ArgumentError, ':in option is required' unless options[:in]

      @klass  = klass
      @name   = name
      @values = Array(options[:in]).map { |v| Value.new(self, v) }
    end

    def attach!
      attr = self
      @klass.singleton_class.class_eval do
        define_method("#{attr.name}") { attr }
      end

      @klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        attr_reader :#{name}

        def #{name}_text
          #{name}.text
        end

        def #{name}=(new_value)
          @#{name} = self.class.#{name}.find_value(new_value)
        end
      RUBY
    end

    def find_value(value)
      value = value.to_s
      values.find { |v| v == value }
    end

    def i18n_suffix
      @klass.model_name.i18n_key if @klass.respond_to?(:model_name)
    end

    def options
      values.map { |v| [v.text, v.to_s] }
    end
  end
end
