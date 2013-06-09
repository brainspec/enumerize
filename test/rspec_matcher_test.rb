require 'test_helper'
require 'enumerize/integrations/rspec'

describe Enumerize::Integrations::RSpec do
  class Should
    include Enumerize::Integrations::RSpec
  end

  let(:klass) do
    Class.new do
      extend Enumerize
    end
  end

  let(:should) { Should.new }
  let(:object) { klass.new }

  describe '#matches?' do
    before do
      klass.enumerize(:sex, :in => [:male, :female])
    end

    it 'returns true' do
      matcher = should.enumerize(:sex).in(:male, :female)
      matcher.matches?(object).must_equal true
    end

    it 'returns false' do
      matcher = should.enumerize(:sex).in(:bar)
      matcher.matches?(object).must_equal false
    end
  end

  describe '#failure_message' do
    before do
      klass.enumerize(:sex, :in => [:male, :female], :default => :male)
    end

    it 'returns failure message for invalid :in option' do
      matcher = should.enumerize(:sex).in(:bar)
      matcher.subject = object
      expected = ' expected :sex to allow value: "bar", but it allows "female", "male" instead'
      matcher.failure_message.must_equal expected
    end

    it 'returns failure message for invalid :with_default option' do
      matcher = should.enumerize(:sex).in(:male, :female).with_default(:foo)
      matcher.subject = object
      expected = ' expected :sex to have "foo" as default value, but it sets "male" instead'
      matcher.failure_message.must_equal expected
    end
  end
end
