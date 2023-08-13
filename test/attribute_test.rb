# frozen_string_literal: true

require 'test_helper'

class AttributeTest < Minitest::Spec
  def attr
    @attr ||= nil
  end

  def build_attr(*args, &block)
    @attr = Enumerize::Attribute.new(*args, &block)
  end

  it 'returns values' do
    build_attr nil, :foo, :in => [:a, :b]
    expect(attr.values).must_equal %w[a b]
  end

  it 'returns frozen values' do
    build_attr nil, :foo, :in => [:a, :b]
    expect(attr.values.map(&:frozen?)).must_equal [true, true]
  end

  it 'converts name to symbol' do
    build_attr nil, 'foo', :in => %w[a b]
    expect(attr.name).must_equal :foo
  end

  it 'uses custom value class' do
    value_class = Class.new(Enumerize::Value)
    build_attr nil, 'foo', :in => %w[a b], :value_class => value_class
    expect(attr.values.first).must_be_instance_of value_class
  end

  describe 'i18n scopes' do
    it 'returns scopes from options' do
      build_attr nil, 'foo', :in => %w[a b], :i18n_scope => %w[bar buzz]
      expect(attr.i18n_scopes).must_equal %w[bar buzz]
    end
  end

  describe 'arguments' do
    it 'returns arguments' do
      build_attr nil, :foo, :in => [:a, :b], :scope => true
      expect(attr.arguments).must_equal({:in => [:a, :b], :scope => true})
    end
  end

  describe 'options for select' do
    it 'returns all options for select' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        expect(attr.options).must_equal [['a text', 'a'], ['b text', 'b']]
      end
    end

    it 'returns requested options for select via :only' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        expect(attr.options(:only => :a)).must_equal [['a text', 'a']]
        expect(attr.options(:only => [:b])).must_equal [['b text', 'b']]
        expect(attr.options(:only => [])).must_equal []
      end
    end

    it 'returns requested options for select via :except' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        expect(attr.options(:except => :a)).must_equal [['b text', 'b']]
        expect(attr.options(:except => :b)).must_equal [['a text', 'a']]
        expect(attr.options(:except => [])).must_equal [['a text', 'a'], ['b text', 'b']]
      end
    end

    it 'does not work with both :only and :except' do
      store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
        build_attr nil, :foo, :in => %w[a b]
        expect(proc { attr.options(:except => [], :only => []) }).must_raise ArgumentError
      end
    end
  end

  describe 'values hash' do
    before do
      build_attr nil, :foo, :in => {:a => 1, :b => 2}
    end

    it 'returns hash keys as values' do
      expect(attr.values).must_equal %w[a b]
    end

    it 'finds values by hash values' do
      expect(attr.find_value(1)).must_equal 'a'
      expect(attr.find_value(2)).must_equal 'b'
    end
  end

  it 'sets up shortcut methods for each value' do
    build_attr nil, :foo, :in => {:a => 1, :b => 2}

    expect(attr).must_respond_to :a
    expect(attr).must_respond_to :b

    expect(attr.a.value).must_equal 1
    expect(attr.b.value).must_equal 2
    expect(attr.a.text).must_equal 'A'
    expect(attr.b.text).must_equal 'B'
  end

  describe 'values hash with zero' do
    before do
      build_attr nil, :foo, :in => {:a => 1, :b => 2, :c => 0}
    end

    it 'returns hash keys as values' do
      expect(attr.values).must_equal %w[a b c]
    end

    it 'finds values by hash values' do
      expect(attr.find_value(1)).must_equal 'a'
      expect(attr.find_value(2)).must_equal 'b'
      expect(attr.find_value(0)).must_equal 'c'
    end

    it 'finds all values by hash values' do
      expect(attr.find_values(1, 2, 0)).must_equal ['a', 'b', 'c']
    end
  end

  describe 'boolean values hash' do
    before do
      build_attr nil, :foo, :in => {:a => true, :b => false}
    end

    it 'returns hash keys as values' do
      expect(attr.values).must_equal %w[a b]
    end

    it 'finds values by hash values' do
      expect(attr.find_value(true)).must_equal 'a'
      expect(attr.find_value(false)).must_equal 'b'
    end
  end
end
