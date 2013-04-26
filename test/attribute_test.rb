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

  describe 'options for select' do
    it 'returns all options for select' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        attr.options.must_equal [['a text', 'a'], ['b text', 'b']]
      end
    end

    it 'returns requested options for select via :only' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        attr.options(:only => :a).must_equal [['a text', 'a']]
        attr.options(:only => [:b]).must_equal [['b text', 'b']]
        attr.options(:only => []).must_equal []
      end
    end

    it 'returns requested options for select via :except' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        attr.options(:except => :a).must_equal [['b text', 'b']]
        attr.options(:except => :b).must_equal [['a text', 'a']]
        attr.options(:except => []).must_equal [['a text', 'a'], ['b text', 'b']]
      end
    end

    it 'does not work with both :only and :except' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        proc { attr.options(:except => [], :only => []) }.must_raise ArgumentError
      end
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
