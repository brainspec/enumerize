module Enumerize
  class Attribute
    attr_reader :name, :values, :default_value

    def initialize(klass, name, options={})
      raise ArgumentError, ':in option is required' unless options[:in]

      extend Multiple if options[:multiple]

      @klass  = klass
      @name   = name.to_sym
      @values = Array(options[:in]).map { |v| Value.new(self, *v) }
      @value_hash = Hash[@values.map { |v| [v.value.to_s, v] }]
      @value_hash.merge! Hash[@values.map { |v| [v.to_s, v] }]

      if default = options[:default]
        if default.respond_to?(:call)
          @default_value = default
        else
          @default_value = find_value(default)
          raise ArgumentError, 'invalid default value' unless @default_value
        end
      end
    end

    def find_value(value)
      @value_hash[value.to_s] unless value.nil?
    end

    def i18n_suffix
      @klass.model_name.i18n_key if @klass.respond_to?(:model_name)
    end

    def options(options = {})
      values = if options.empty?
        @values
      else
        raise ArgumentError, 'Options cannot have both :only and :except' if options[:only] && options[:except]

        only = Array(options[:only]).map(&:to_s)
        except = Array(options[:except]).map(&:to_s)

        @values.reject do |value|
          if options[:only]
            !only.include?(value)
          elsif options[:except]
            except.include?(value)
          end
        end
      end

      values.map { |v| [v.text, v.to_s] }
    end

    def define_methods!(mod)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          if defined?(super)
            self.class.enumerized_attributes[:#{name}].find_value(super)
          elsif respond_to?(:read_attribute)
            self.class.enumerized_attributes[:#{name}].find_value(read_attribute(:#{name}))
          else
            if defined?(@#{name})
              self.class.enumerized_attributes[:#{name}].find_value(@#{name})
            else
              @#{name} = nil
            end
          end
        end

        def #{name}=(new_value)
          _enumerized_values_for_validation[:#{name}] = new_value.nil? ? nil : new_value.to_s

          allowed_value_or_nil = self.class.enumerized_attributes[:#{name}].find_value(new_value)
          allowed_value_or_nil = allowed_value_or_nil.value unless allowed_value_or_nil.nil?

          if defined?(super)
            super allowed_value_or_nil
          elsif respond_to?(:write_attribute, true)
            write_attribute '#{name}', allowed_value_or_nil
          else
            @#{name} = allowed_value_or_nil
          end
        end

        def #{name}_text
          self.#{name} && self.#{name}.text
        end

        def #{name}_value
          self.#{name} && self.#{name}.value
        end
      RUBY
    end
  end

  module Multiple
    def define_methods!(mod)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          unless defined?(@_#{name}_enumerized_set)
            if defined?(super)
              self.#{name} = super
            else
              if defined?(@#{name})
                self.#{name} = @#{name}
              else
                self.#{name} = []
              end
            end
          end

          @_#{name}_enumerized_set
        end

        def #{name}=(values)
          _enumerized_values_for_validation[:#{name}] = values.respond_to?(:map) ? values.map(&:to_s) : values

          @_#{name}_enumerized_set = Enumerize::Set.new(self, self.class.enumerized_attributes[:#{name}], values)
          string_values = #{name}.values.map(&:to_str)

          if defined?(super)
            super string_values
          elsif respond_to?(:write_attribute, true)
            write_attribute '#{name}', string_values
          else
            @#{name} = string_values
          end

          #{name}
        end
      RUBY
    end
  end
end
