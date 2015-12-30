require 'active_support/core_ext/module/delegation'

module Enumerize
  # Predicate methods.
  #
  # Basic usage:
  #
  #     class User
  #       extend Enumerize
  #       enumerize :sex, in: %w(male female), predicates: true
  #     end
  #
  #     user = User.new
  #
  #     user.male?   # => false
  #     user.female? # => false
  #
  #     user.sex = 'male'
  #
  #     user.male?   # => true
  #     user.female? # => false
  #
  # Using prefix:
  #
  #     class User
  #       extend Enumerize
  #       enumerize :sex, in: %w(male female), predicates: { prefix: true }
  #     end
  #
  #     user = User.new
  #     user.sex = 'female'
  #     user.sex_female? # => true
  #
  # Use <tt>only</tt> and <tt>except</tt> options to specify what values create
  # predicate methods for.
  module Predicates
    def enumerize(name, options={})
      super

      if options[:predicates]
        Builder.new(enumerized_attributes[name], options[:predicates]).build(_enumerize_module)
      end
    end

    class Builder
      def initialize(attr, options)
        @attr    = attr
        @options = options.is_a?(Hash) ? options : {}
      end

      def values
        values = @attr.values

        if @options[:only]
          values &= Array(@options[:only]).map(&:to_s)
        end

        if @options[:except]
          values -= Array(@options[:except]).map(&:to_s)
        end

        values
      end

      def names
        values.map { |v| "#{v.tr('-', '_')}?" }
      end

      def build(klass)
        klass.delegate(*names, to: @attr.name, prefix: @options[:prefix], allow_nil: true)
      end
    end
  end
end
