module Enumerize
  module ActiveRecordSupport
    def enumerize(name, options={})
      super

      _enumerize_module.dependent_eval do
        if defined?(::ActiveRecord::Base) && self < ::ActiveRecord::Base
          include InstanceMethods

          # Since Rails use `allocate` method on models and initializes them with `init_with` method.
          # This way `initialize` method is not being called, but `after_initialize` callback always gets triggered.
          after_initialize :_set_default_value_for_enumerized_attributes

          # https://github.com/brainspec/enumerize/issues/111
          require 'enumerize/hooks/uniqueness'
        elsif defined?(::Mongoid::Document) and self < ::Mongoid::Document
          if options[:scope]
            _define_scope_methods!(name, options)
          end

          include InstanceMethods

          after_initialize :_set_default_value_for_enumerized_attributes
        end
      end
    end

    module InstanceMethods
      # https://github.com/brainspec/enumerize/issues/74
      def write_attribute(attr_name, value)
        if self.class.enumerized_attributes[attr_name]
          _enumerized_values_for_validation[attr_name.to_s] = value
        end

        super
      end

      # Support multiple enumerized attributes
      def becomes(klass)
        became = super
        klass.enumerized_attributes.each do |attr|
          became.send("#{attr.name}=", send(attr.name))
        end

        became
      end
    end
  end
end
