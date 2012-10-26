require 'test_helper'

describe Enumerize::Set do
  let(:klass) do
    Class.new do
      extend Enumerize
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

  def assert_called(object, method)
    called = false

    object.singleton_class.class_eval do
      define_method method do |*args, &block|
        called = true
        super(*args, &block)
      end
    end

    yield

    assert called, "Expected ##{method} to be called"
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

  it 'equals to array with different value order' do
    set << :b
    set.must_equal %w(b a)
  end

  it "isn't equal to a part of values" do
    set << :b
    set.wont_equal %w(a)
  end

  describe '#push' do
    it 'appends values' do
      set.push :b
      set.must_include :b
    end

    it 'reassigns attribute' do
      assert_called object, :foo= do
        set.push :b
      end
    end
  end

  describe '#delete' do
    it 'deletes value' do
      set.delete :a
      set.wont_include :a
    end

    it 'reassigns attribute' do
      assert_called object, :foo= do
        set.delete :a
      end
    end
  end

  describe '#inspect' do
    it 'returns custom string' do
      set << :b
      set.inspect.must_equal '#<Enumerize::Set {a, b}>'
    end
  end

  describe '#to_ary' do
    it 'returns array' do
      set.to_ary.must_be_instance_of Array
    end
  end

  describe '#join' do
    it 'joins values' do
      set << :b
      set.join(', ').must_equal 'a, b'
    end
  end
end
