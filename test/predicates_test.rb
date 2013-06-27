require 'test_helper'

describe Enumerize::Predicates do
  let(:klass) do
    Class.new do
      extend Enumerize
    end
  end

  let(:object) { klass.new }

  it 'creates predicate methods' do
    klass.enumerize(:foo, in: %w(a b), predicates: true)
    object.must_respond_to :a?
    object.must_respond_to :b?
  end

  it 'creates predicate methods on multiple attribute' do
    klass.enumerize(:foo, in: %w(a b), predicates: true, multiple: true)
    object.must_respond_to :a?
    object.must_respond_to :b?
  end

  it 'checks values' do
    klass.enumerize(:foo, in: %w(a b), predicates: true)
    object.foo = 'a'
    object.a?.must_equal true
    object.b?.must_equal false
  end

  it 'checks values on multiple attribute' do
    klass.enumerize(:foo, in: %w(a b), predicates: true, multiple: true)
    object.foo << :a
    object.a?.must_equal true
    object.b?.must_equal false
  end

  it 'prefixes methods' do
    klass.enumerize(:foo, in: %w(a b), predicates: { prefix: 'bar' })
    object.wont_respond_to :a?
    object.wont_respond_to :b?
    object.must_respond_to :bar_a?
    object.must_respond_to :bar_b?
  end

  it 'accepts only option' do
    klass.enumerize(:foo, in: %w(a b), predicates: { only: :a })
    object.must_respond_to :a?
    object.wont_respond_to :b?
  end

  it 'accepts except option' do
    klass.enumerize(:foo, in: %w(a b), predicates: { except: :a })
    object.wont_respond_to :a?
    object.must_respond_to :b?
  end
end
