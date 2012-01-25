module Enumerize
  class Attribute
    attr_reader :name, :values, :default_value

    def initialize(klass, name, options={})
      raise ArgumentError, ':in option is required' unless options[:in]

      @klass  = klass
      @name   = name
      @values = Array(options[:in]).map { |v| Value.new(self, v) }

      if options[:default]
        @default_value = options[:default] && find_value(options[:default])
        raise ArgumentError, 'invalid default value' unless @default_value
      end
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
