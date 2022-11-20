# frozen_string_literal: true

require 'test_helper'
require 'yaml'

class SetTest < MiniTest::Spec
  let(:kklass) do
    Class.new do
      extend Enumerize
      enumerize :foo, :in => %w(a b c), :multiple => true
    end
  end

  let(:object) { kklass.new }

  def build_set(values)
    @set = Enumerize::Set.new(object, kklass.foo, values)
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
    expect(set).must_equal Enumerize::Set.new(nil, kklass.foo, %w(a))
  end

  it 'equals to array' do
    expect(set).must_equal %w(a)
  end

  it 'equals to array of symbols' do
    expect(set).must_equal [:a]
  end

  it 'has unique values' do
    set << :a
    expect(set).must_equal %w(a)
  end

  it 'equals to array with different value order' do
    set << :b
    expect(set).must_equal %w(b a)
  end

  it "isn't equal to a part of values" do
    set << :b
    expect(set).wont_equal %w(a)
  end

  describe '#push' do
    it 'appends values' do
      set.push :b
      expect(set).must_include :b
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
      expect(set).wont_include :a
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
      expect(set.inspect).must_equal '#<Enumerize::Set {a, b}>'
    end
  end

  describe '#to_ary' do
    it 'returns array' do
      expect(set.to_ary).must_be_instance_of Array
    end
  end

  describe '#texts' do
    it 'returns array of text values' do
      expect(set.texts).must_equal ['A']
    end
  end

  describe '#join' do
    it 'joins values' do
      set << :b
      expect(set.join(', ')).must_equal 'a, b'
    end
  end

  describe 'boolean methods comparison' do
    it 'returns true if value equals method' do
      set << :a
      expect(set.a?).must_equal true
    end

    it 'returns false if value does not equal method' do
      set << :a
      expect(set.b?).must_equal false
    end

    it 'raises NoMethodError if there are no values like boolean method' do
      expect(proc {
        set.some_method?
      }).must_raise NoMethodError
    end

    it 'raises ArgumentError if arguments are passed' do
      expect(proc {
        set.a?('<3')
      }).must_raise ArgumentError
    end

    it 'responds to methods for existing values' do
      expect(set).must_respond_to :a?
      expect(set).must_respond_to :b?
      expect(set).must_respond_to :c?
    end

    it 'returns a method object' do
      expect(set.method(:a?)).must_be_instance_of Method
    end

    it 'does not respond to a method for not existing value' do
      expect(set).wont_respond_to :some_method?
    end
  end

  describe 'serialization' do
    it 'is serialized to yaml as array' do
      set << :a
      assert_equal YAML.dump(%w(a)), YAML.dump(set)
    end
  end
end
