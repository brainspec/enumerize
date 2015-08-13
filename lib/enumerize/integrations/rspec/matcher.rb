module Enumerize
  module Integrations
    module RSpec
      class Matcher

        def initialize(expected_attr)
          self.expected_attr = expected_attr
        end

        def in(*expected_values)
          self.expected_values = expected_values
          self
        end

        def with_default(expected_default)
          self.expected_default = expected_default.to_s
          self
        end

        def with_i18n_scope(expected_i18n_scope)
          self.expected_i18n_scope = expected_i18n_scope
          self
        end

        def failure_message
          "Expected #{expectation}"
        end

        def failure_message_when_negated
          "Did not expect #{expectation}"
        end

        def description
          description  = "define enumerize :#{expected_attr}"
          description += " in: #{quote_values(expected_values)}" if expected_values
          description += " with #{expected_default.inspect} as default value" if expected_default
          description += " i18n_scope: #{expected_i18n_scope.inspect}" if expected_i18n_scope

          description
        end

        def matches?(subject)
          self.subject = subject
          matches      = true

          matches &= matches_attribute?
          matches &= matches_values? if expected_values
          matches &= matches_default_value? if expected_default
          matches &= matches_i18n_scope? if expected_i18n_scope

          matches
        end

        private
        attr_accessor :expected_attr, :expected_values, :subject, :expected_default,
                      :expected_i18n_scope

        def expectation
          "#{subject.class.name} to #{description}"
        end

        def matches_attribute?
          attributes.present?
        end

        def matches_values?
          matches_array_values? || matches_hash_values?
        end

        def matches_array_values?
          sorted_values == enumerized_values
        end

        def matches_hash_values?
          return unless expected_values.first.is_a?(Hash)
          expected_values.first.all? { |k, v| enumerized_value_hash[k.to_s] == v; }
        end

        def matches_default_value?
          expected_default == enumerized_default
        end

        def matches_i18n_scope?
          attributes.i18n_scope == expected_i18n_scope
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
          subject.class.enumerized_attributes.attributes[expected_attr.to_s]
        end

        def quote_values(values)
          sorted_values.map(&:inspect).join(', ')
        end
      end
    end
  end
end
