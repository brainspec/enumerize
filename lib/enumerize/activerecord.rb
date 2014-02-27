module Enumerize
  module ActiveRecordSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if defined?(::ActiveRecord::Base) && self < ::ActiveRecord::Base
          if options[:scope]
            _define_scope_methods!(name, options)
          end

          include InstanceMethods

          # Since Rails use `allocate` method on models and initializes them with `init_with` method.
          # This way `initialize` method is not being called, but `after_initialize` callback always gets triggered.
          after_initialize :_set_default_value_for_enumerized_attributes

          # https://github.com/brainspec/enumerize/issues/111
          require 'enumerize/hooks/uniqueness'
        end
      end
    end

    private

    def _define_scope_methods!(name, options)
      scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]

      define_singleton_method scope_name do |*values|
        values = values.map { |value| enumerized_attributes[name].find_value(value).value }
        values = values.first if values.size == 1

        where(name => values)
      end

      if options[:scope] == true
        define_singleton_method "without_#{name}" do |*values|
          values = values.map { |value| enumerized_attributes[name].find_value(value).value }
          where(arel_table[name].not_in(values))
        end
      end
    end

    module InstanceMethods
      # https://github.com/brainspec/enumerize/issues/74
      def write_attribute(attr_name, value)
        if self.class.enumerized_attributes[attr_name]
          _enumerized_values_for_validation[attr_name] = value
        end

        super
      end

      # Support multiple enumerized attributes
      def becomes(klass)
        became = super
        klass.enumerized_attributes.each do |attr|
          if attr.is_a? Multiple
            became.send("#{attr.name}=", send(attr.name))
          end
        end

        became
      end
    end
  end
end
