require 'test_helper'

describe Enumerize::Base do
  let(:klass) do
    Class.new do
      extend Enumerize
    end
  end

  let(:subklass) do
    Class.new(klass)
  end

  let(:object) { klass.new }

  it 'returns [] when not set' do
    klass.enumerize :foos, in: %w(a b), multiple: true
    object.foos.must_equal []
  end

  it 'returns setted array' do
    klass.enumerize :foos, in: %w(a b c), multiple: true
    object.foos = %w(a c)
    object.foos.must_equal %w(a c)
  end

  it "doesn't define _text method" do
    klass.enumerize :foos, in: %w(a b c), multiple: true
    object.wont_respond_to :foos_text
  end

  it "doesn't define _value method" do
    klass.enumerize :foos, in: %w(a b c), multiple: true
    object.wont_respond_to :foos_value
  end
end
