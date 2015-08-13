module Enumerize
  module Integrations
    module RSpec
      class Matcher

        def initialize(attr)
          self.attr = attr
        end

        def in(*expected_values)
          self.expected_values = expected_values
          self
        end

        def with_default(expected_default)
          self.expected_default = expected_default.to_s
          self
        end

        def failure_message
          "Expected #{expectation}"
        end

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end

        def description
          description  = "define enumerize :#{attr} in: #{quote_values(expected_values)}"
          description += " with #{expected_default.inspect} as default value" if expected_default

          description
        end

        def matches?(subject)
          self.subject = subject
          matches      = true

          matches &= matches_attributes?
          matches &= matches_default_value? if expected_default

          matches
        end

        private
        attr_accessor :attr, :expected_values, :subject, :expected_default

        def expectation
          "#{subject.class.name} to #{description}"
        end

        def matches_attributes?
          matches_array_attributes? || matches_hash_attributes?
        end

        def matches_array_attributes?
          sorted_values == enumerized_values
        end

        def matches_hash_attributes?
          return unless expected_values.first.is_a?(Hash)
          expected_values.first.all? { |k, v| enumerized_value_hash[k.to_s] == v; }
        end

        def matches_default_value?
          expected_default == enumerized_default
        end

        def sorted_values
          @sorted_values ||=expected_values.map(&:to_s).sort
        end

        def enumerized_values
          @enumerized_values ||= attributes.values.sort
        end

        def enumerized_default
          @enumerized_default ||= attributes.default_value
        end

        def enumerized_value_hash
          @enumerized_value_hash ||= attributes.instance_variable_get('@value_hash')
        end

        def attributes
          subject.class.enumerized_attributes.attributes[attr.to_s]
        end

        def quote_values(values)
          sorted_values.map(&:inspect).join(', ')
        end
      end
    end
  end
end
