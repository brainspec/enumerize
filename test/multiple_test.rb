require 'test_helper'

describe Enumerize::Base do
  let(:klass) do
    Class.new do
      include Enumerize
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
end
