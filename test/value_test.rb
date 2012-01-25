require 'test_helper'
require 'yaml'

describe Enumerize::Value do
  let(:value) { Enumerize::Value.new(nil, 'test_value') }

  it 'is a string' do
    value.must_be_kind_of String
  end

  it 'is compared to string' do
    value.must_be :==, 'test_value'
  end

  it 'is frozen' do
    value.must_be :frozen?
  end
end
