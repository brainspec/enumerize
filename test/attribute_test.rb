require 'test_helper'

describe Enumerize::Attribute do
  def attr
    @attr ||= nil
  end

  def build_attr(*args, &block)
    @attr = Enumerize::Attribute.new(*args, &block)
  end

  it 'returns values' do
    build_attr nil, :foo, :in => [:a, :b]
    attr.values.must_equal %w[a b]
  end

  it 'converts name to symbol' do
    build_attr nil, 'foo', :in => %w[a b]
    attr.name.must_equal :foo
  end

  it 'returns options for select' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
      build_attr nil, :foo, :in => %w[a b]
      attr.options.must_equal [['a text', 'a'], ['b text', 'b']]
    end
  end

  describe 'values hash' do
    before do
      build_attr nil, :foo, :in => {:a => 1, :b => 2}
    end

    it 'returns hash keys as values' do
      attr.values.must_equal %w[a b]
    end

    it 'finds values by hash values' do
      attr.find_value(1).must_equal 'a'
      attr.find_value(2).must_equal 'b'
    end
  end
end
