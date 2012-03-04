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
end
