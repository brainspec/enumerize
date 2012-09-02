require 'test_helper'

describe Enumerize::Value do
  let(:attr)  { Struct.new(:values).new([]) }
  let(:value) { Enumerize::Value.new(attr, 'test_value') }

  it 'is a string' do
    value.must_be_kind_of String
  end

  it 'is compared to string' do
    value.must_be :==, 'test_value'
  end

  describe 'boolean methods comparison' do
    before do
      attr.values = [value, Enumerize::Value.new(attr, 'other_value')]
    end

    it 'returns true if value equals method' do
      value.test_value?.must_equal true
    end

    it 'returns false if value does not equal method' do
      value.other_value?.must_equal false
    end

    it 'raises NoMethodError if there are no values like boolean method' do
      proc {
        value.some_method?
      }.must_raise NoMethodError
    end

    it 'raises ArgumentError if arguments are passed' do
      proc {
        value.other_value?('<3')
      }.must_raise ArgumentError
    end

    it 'responds to methods for existing values' do
      value.must_respond_to :test_value?
      value.must_respond_to :other_value?
    end

    it 'returns a method object' do
      value.method(:test_value?).must_be_instance_of Method
    end

    it "doesn't respond to a method for not existing value" do
      value.wont_respond_to :some_method?
    end
  end
end
