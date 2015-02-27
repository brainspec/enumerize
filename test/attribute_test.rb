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

  it 'uses custom value class' do
    value_class = Class.new(Enumerize::Value)
    build_attr nil, 'foo', :in => %w[a b], :value_class => value_class
    attr.values.first.must_be_instance_of value_class
  end

  describe 'i18n scopes' do
    it 'returns scopes from options' do
      build_attr nil, 'foo', :in => %w[a b], :i18n_scope => %w[bar buzz]
      attr.i18n_scopes.must_equal %w[bar buzz]
    end

    it 'accepts only string scopes' do
      proc { build_attr nil, 'foo', :in => %w[a b], :i18n_scope => [%w[bar buzz], "bar.buzz"] }.must_raise ArgumentError
    end
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

  it 'sets up shortcut methods for each value' do
    build_attr nil, :foo, :in => {:a => 1, :b => 2}

    attr.must_respond_to :a
    attr.must_respond_to :b

    attr.a.value.must_equal 1
    attr.b.value.must_equal 2
    attr.a.text.must_equal 'A'
    attr.b.text.must_equal 'B'
  end

  describe 'values hash with zero' do
    before do
      build_attr nil, :foo, :in => {:a => 1, :b => 2, :c => 0}
    end

    it 'returns hash keys as values' do
      attr.values.must_equal %w[a b c]
    end

    it 'finds values by hash values' do
      attr.find_value(1).must_equal 'a'
      attr.find_value(2).must_equal 'b'
      attr.find_value(0).must_equal 'c'
    end

    it 'finds all values by hash values' do
      attr.find_values(1, 2, 0).must_equal ['a', 'b', 'c']
    end
  end

  describe 'boolean values hash' do
    before do
      build_attr nil, :foo, :in => {:a => true, :b => false}
    end

    it 'returns hash keys as values' do
      attr.values.must_equal %w[a b]
    end

    it 'finds values by hash values' do
      attr.find_value(true).must_equal 'a'
      attr.find_value(false).must_equal 'b'
    end
  end
end
