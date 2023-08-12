# frozen_string_literal: true

require 'test_helper'

class BaseTest < Minitest::Spec
  let(:kklass) do
    Class.new do
      extend Enumerize
    end
  end

  let(:subklass) do
    Class.new(kklass)
  end

  let(:object) { kklass.new }

  it 'returns nil when not set' do
    kklass.enumerize(:foo, :in => [:a, :b])
    expect(object.foo).must_be_nil
  end

  it 'returns value that was set' do
    kklass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    expect(object.foo).must_equal 'a'
  end

  it 'returns translation' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text'}}) do
      kklass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      expect(object.foo.text).must_equal 'a text'
      expect(object.foo_text).must_equal 'a text'
      expect(object.foo_text).must_equal 'a text'
    end
  end

  it 'returns nil as translation when value is nil' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text'}}) do
      kklass.enumerize(:foo, :in => [:a, :b])
      expect(object.foo_text).must_be_nil
    end
  end

  it 'scopes translation by i18n key' do
    def kklass.model_name
      name = String.new("ExampleClass")
      def name.i18n_key
        'example_class'
      end

      name
    end

    store_translations(:en, :enumerize => {:example_class => {:foo => {:a => 'a text scoped'}}}) do
      kklass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      expect(object.foo.text).must_equal 'a text scoped'
      expect(object.foo_text).must_equal 'a text scoped'
    end
  end

  it 'returns humanized value if there are no translations' do
    store_translations(:en, :enumerize => {}) do
      kklass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      expect(object.foo_text).must_equal 'A'
    end
  end

  it 'stores value as string' do
    kklass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    expect(object.instance_variable_get(:@foo)).must_be_instance_of String
  end

  it 'handles default value' do
    kklass.enumerize(:foo, :in => [:a, :b], :default => :b)
    expect(object.foo).must_equal 'b'
  end

  it 'handles default value with lambda' do
    kklass.enumerize(:foo, :in => [:a, :b], :default => lambda { :b })
    expect(object.foo).must_equal 'b'
  end

  it 'injects object instance into lamda default value' do
    kklass.enumerize(:foo, :in => [:a, :b], :default => lambda { |obj| :b if obj.is_a? kklass })
    expect(object.foo).must_equal 'b'
  end

  it 'raises exception on invalid default value' do
    expect(proc {
      kklass.enumerize(:foo, :in => [:a, :b], :default => :c)
    }).must_raise ArgumentError
  end

  it 'has enumerized attributes' do
    expect(kklass.enumerized_attributes).must_be_empty
    kklass.enumerize(:foo, :in => %w[a b])
    expect(kklass.enumerized_attributes[:foo]).must_be_instance_of Enumerize::Attribute
  end

  it "doesn't override existing method" do
    method = kklass.method(:name)
    kklass.enumerize(:name, :in => %w[a b], :default => 'a')
    expect(kklass.method(:name)).must_equal method
  end

  it "inherits enumerized attributes from a parent class" do
    kklass.enumerize(:foo, :in => %w[a b])
    expect(subklass.enumerized_attributes[:foo]).must_be_instance_of Enumerize::Attribute
  end

  it "inherits enumerized attributes from a grandparent class" do
    kklass.enumerize(:foo, :in => %w[a b])
    expect(Class.new(subklass).enumerized_attributes[:foo]).must_be_instance_of Enumerize::Attribute
  end

  it "doesn't add enumerized attributes to parent class" do
    kklass.enumerize(:foo, :in => %w[a b])
    subklass.enumerize(:bar, :in => %w[c d])

    expect(kklass.enumerized_attributes[:bar]).must_be_nil
  end

  it 'adds new parent class attributes to subclass' do
    subklass = Class.new(kklass)
    kklass.enumerize :foo, :in => %w[a b]
    expect(subklass.enumerized_attributes[:foo]).must_be_instance_of Enumerize::Attribute
  end

  it 'stores nil value' do
    kklass.enumerize(:foo, :in => [:a, :b])
    object.foo = nil
    expect(object.instance_variable_get(:@foo)).must_be_nil
  end

  it 'casts value to string for validation' do
    kklass.enumerize(:foo, :in => [:a, :b])
    object.foo = :c
    expect(object.read_attribute_for_validation(:foo)).must_equal 'c'
  end

  it "doesn't cast nil to string for validation" do
    kklass.enumerize(:foo, :in => [:a, :b])
    object.foo = nil
    expect(object.read_attribute_for_validation(:foo)).must_be_nil
  end

  it 'calls super in the accessor method' do
    accessors = Module.new do
      def attributes
        @attributes ||= {}
      end

      def foo
        attributes[:foo]
      end

      def foo=(v)
        attributes[:foo] = v
      end
    end

    klass = Class.new do
      include accessors
      extend Enumerize

      enumerize :foo, :in => %w[test]
    end

    object = klass.new
    expect(object.foo).must_be_nil
    expect(object.attributes).must_equal({})

    object.foo = 'test'
    expect(object.foo).must_equal 'test'
    expect(object.attributes).must_equal(:foo => 'test')
  end

  it 'stores hash values' do
    kklass.enumerize(:foo, :in => {:a => 1, :b => 2})

    object.foo = :a
    expect(object.instance_variable_get(:@foo)).must_equal 1
    expect(object.foo).must_equal 'a'

    object.foo = :b
    expect(object.instance_variable_get(:@foo)).must_equal 2
    expect(object.foo).must_equal 'b'
  end

  it 'returns custom value' do
    kklass.enumerize(:foo, :in => {:a => 1, :b => 2})

    object.foo = :a
    expect(object.foo_value).must_equal 1

    object.foo = :b
    expect(object.foo_value).must_equal 2
  end

  it 'allows initialize method with arguments' do
    klass = Class.new do
      extend Enumerize

      def initialize(argument, key_word_argument: nil); end
    end

    klass.new('arg1', key_word_argument: 'kwargs1')
  end

  it 'allows initialize method with arguments for inherited classes' do
    parent_klass = Class.new do
      def initialize(argument, key_word_argument: nil); end
    end

    klass = Class.new(parent_klass) do
      extend Enumerize

      def initialize(argument, key_word_argument: nil)
        super
      end
    end

    klass.new('arg1', key_word_argument: 'kwargs1')
  end

  it 'allows initializing object without keyword arguments' do
    parent_klass = Class.new do
      attr_reader :arguments

      def initialize(arguments)
        @arguments = arguments
      end
    end

    klass = Class.new(parent_klass) do
      extend Enumerize

      def initialize(arguments)
        super
      end
    end

    params = { 'string_key' => 1, symbol_key: 2 }

    object = klass.new(params)

    expect(object.arguments).must_equal params
  end
end
