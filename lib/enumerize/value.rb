require 'i18n'

module Enumerize
  class Value < String
    include Predicatable

    attr_reader :value

    def initialize(attr, name, value=nil)
      @attr  = attr
      @value = value.nil? ? name.to_s : value

      super(name.to_s)
    end

    def text
      I18n.t(i18n_keys[0], :default => i18n_keys[1..-1])
    end

    def encode_with(coder)
      coder.represent_object(self.class.superclass, @value)
    end

    private

    def define_query_method(value)
      singleton_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{value}?
          #{value == self}
        end
      RUBY
    end

    def i18n_keys
      @i18n_keys ||= begin
        i18n_keys = i18n_scopes
        i18n_keys << [:"enumerize.defaults.#{@attr.name}.#{self}"]
        i18n_keys << [:"enumerize.#{@attr.name}.#{self}"]

        # if there are no translations
        i18n_keys << if @attr.text_transform.nil?
                       self.underscore.humanize
                     else
                       @attr.text_transform.call(self)
                     end

        i18n_keys.flatten
      end
    end

    def i18n_scopes
      @attr.i18n_scopes.map { |s| :"#{s}.#{self}" }
    end
  end
end
