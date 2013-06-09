require 'enumerize/integrations/rspec/matcher'

module Enumerize
  module Integrations
    module RSpec
      def enumerize(attr)
        ::Enumerize::Integrations::RSpec::Matcher.new(attr)
      end
    end
  end
end

module RSpec
  module Matchers
    include Enumerize::Integrations::RSpec
  end
end
