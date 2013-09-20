module Enumerize
  module Integrations
    module RSpec
      class Matcher
        attr_accessor :attr, :values, :subject, :default

        def initialize(attr)
          self.attr = attr
        end

        def in(*values)
          self.values = values.map(&:to_s).sort
          self
        end

        def with_default(default)
          self.default = default.to_s
          self
        end

        def failure_message
          message  = " expected :#{attr} to allow value#{values.size == 1 ? nil : 's'}: #{quote_values(values)},"
          message += " but it allows #{quote_values(enumerized_values)} instead"

          if default && !matches_default_value?
            message  = " expected :#{attr} to have #{default.inspect} as default value,"
            message += " but it sets #{enumerized_default.inspect} instead"
          end

          message
        end

        def description
          description  = "enumerize :#{attr} in: #{quote_values(values)}"
          description += " with #{default.inspect} as default value" if default

          description
        end

        def matches?(subject)
          self.subject = subject
          matches      = true

          matches &= matches_attributes?
          matches &= matches_default_value? if default

          matches
        end

        private

        def matches_attributes?
          values == enumerized_values
        end

        def matches_default_value?
          default == enumerized_default
        end

        def enumerized_values
          @enumerized_values ||= attributes[attr.to_s].values.sort
        end

        def enumerized_default
          @enumerized_default ||= attributes[attr.to_s].default_value
        end

        def attributes
          subject.class.enumerized_attributes.attributes
        end

        def quote_values(values)
          values.map(&:inspect).join(', ')
        end
      end
    end
  end
end
