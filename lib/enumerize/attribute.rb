module Enumerize
  class Attribute
    attr_reader :klass, :name, :values, :default_value, :i18n_scope

    def initialize(klass, name, options={})
      raise ArgumentError, ':in option is required' unless options[:in]
      raise ArgumentError, ':scope option does not work with option :multiple' if options[:multiple] && options[:scope]

      extend Multiple if options[:multiple]

      @klass  = klass
      @name   = name.to_sym

      value_class = options.fetch(:value_class, Value)
      @values = Array(options[:in]).map { |v| value_class.new(self, *v) }

      @value_hash = Hash[@values.map { |v| [v.value.to_s, v] }]
      @value_hash.merge! Hash[@values.map { |v| [v.to_s, v] }]

      if options[:i18n_scope]
        raise ArgumentError, ':i18n_scope option accepts only String or Array of strings' unless Array(options[:i18n_scope]).all? { |s| s.is_a?(String) }
        @i18n_scope = options[:i18n_scope]
      end

      if options[:default]
        @default_value = find_default_value(options[:default])
        raise ArgumentError, 'invalid default value' unless @default_value
      end
    end

    def find_default_value(value)
      if value.respond_to?(:call)
        value
      else
        find_value(value)
      end
    end

    def find_value(value)
      @value_hash[value.to_s] unless value.nil?
    end

    def find_values(*values)
      values.map { |value| find_value(value) }.compact
    end

    def i18n_scopes
      @i18n_scopes ||= if i18n_scope
        scopes = Array(i18n_scope)
      elsif @klass.respond_to?(:model_name)
        scopes = ["enumerize.#{@klass.model_name.i18n_key}.#{name}"]
      else
        []
      end
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

    def respond_to_missing?(method, include_private=false)
      @value_hash.include?(method.to_s) || super
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
          allowed_value_or_nil = self.class.enumerized_attributes[:#{name}].find_value(new_value)
          allowed_value_or_nil = allowed_value_or_nil.value unless allowed_value_or_nil.nil?

          if defined?(super)
            super allowed_value_or_nil
          elsif respond_to?(:write_attribute, true)
            write_attribute '#{name}', allowed_value_or_nil
          else
            @#{name} = allowed_value_or_nil
          end

          _enumerized_values_for_validation['#{name}'] = new_value.nil? ? nil : new_value.to_s

          allowed_value_or_nil
        end

        def #{name}_text
          self.#{name} && self.#{name}.text
        end

        def #{name}_value
          self.#{name} && self.#{name}.value
        end
      RUBY
    end

    private

    def method_missing(method)
      if @value_hash.include?(method.to_s)
        find_value(method)
      else
        super
      end
    end
  end

  module Multiple
    def find_default_value(value)
      if value.respond_to?(:call)
        value
      else
        find_values(*value)
      end
    end

    def define_methods!(mod)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          unless defined?(@_#{name}_enumerized_set)
            if defined?(super)
              self.#{name} = super
            elsif respond_to?(:read_attribute)
              self.#{name} = read_attribute(:#{name})
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
          @_#{name}_enumerized_set = Enumerize::Set.new(self, self.class.enumerized_attributes[:#{name}], values)
          raw_values = #{name}.values.map(&:value)

          if defined?(super)
            super raw_values
          elsif respond_to?(:write_attribute, true)
            write_attribute '#{name}', raw_values
          else
            @#{name} = raw_values
          end

          _enumerized_values_for_validation['#{name}'] = values.respond_to?(:map) ? values.reject(&:blank?).map(&:to_s) : values

          #{name}
        end
      RUBY
    end
  end
end
