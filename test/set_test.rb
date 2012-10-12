require 'test_helper'

describe Enumerize::Set do
  let(:klass) do
    Class.new do
      include Enumerize
      enumerize :foo, :in => %w(a b c), :multiple => true
    end
  end

  let(:object) { klass.new }

  def build_set(values)
    @set = Enumerize::Set.new(object, klass.foo, values)
  end

  def set
    @set
  end

  before do
    build_set %w(a)
  end

  it 'equals to other set' do
    set.must_equal Enumerize::Set.new(nil, klass.foo, %w(a))
  end

  it 'equals to array' do
    set.must_equal %w(a)
  end

  it 'equals to array of symbols' do
    set.must_equal [:a]
  end

  it 'has unique values' do
    set << :a
    set.must_equal %w(a)
  end

  describe '#push' do
    it 'appends values' do
      set.push :b
      set.must_include :b
    end
  end
end
