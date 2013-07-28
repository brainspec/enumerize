require 'test_helper'

describe Enumerize::Base do
  let(:klass) do
    Class.new do
      extend Enumerize
    end
  end

  let(:subklass) do
    Class.new(klass)
  end

  let(:object) { klass.new }

  it 'returns nil when not set' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo.must_equal nil
  end

  it 'returns value that was set' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    object.foo.must_equal 'a'
  end

  it 'returns translation' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text'}}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      object.foo.text.must_equal 'a text'
      object.foo_text.must_equal 'a text'
      object.foo_text.must_equal 'a text'
    end
  end

  it 'returns nil as translation when value is nil' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text'}}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo_text.must_equal nil
    end
  end

  it 'scopes translation by i18 key' do
    def klass.model_name
      name = "ExampleClass"
      def name.i18n_key
        'example_class'
      end

      name
    end

    store_translations(:en, :enumerize => {:example_class => {:foo => {:a => 'a text scoped'}}}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      object.foo.text.must_equal 'a text scoped'
      object.foo_text.must_equal 'a text scoped'
    end
  end

  it 'returns humanized value if there are no translations' do
    store_translations(:en, :enumerize => {}) do
      klass.enumerize(:foo, :in => [:a, :b])
      object.foo = :a
      object.foo_text.must_equal 'A'
    end
  end

  it 'stores value as string' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    object.instance_variable_get(:@foo).must_be_instance_of String
  end

  it 'handles default value' do
    klass.enumerize(:foo, :in => [:a, :b], :default => :b)
    object.foo.must_equal 'b'
  end

  it 'handles default value with lambda' do
    klass.enumerize(:foo, :in => [:a, :b], :default => lambda { :b })
    object.foo.must_equal 'b'
  end

  it 'injects object instance into lamda default value' do
    klass.enumerize(:foo, :in => [:a, :b], :default => lambda { |obj| :b if obj.is_a? klass })
    object.foo.must_equal 'b'
  end

  it 'raises exception on invalid default value' do
    proc {
      klass.enumerize(:foo, :in => [:a, :b], :default => :c)
    }.must_raise ArgumentError
  end

  it 'has enumerized attributes' do
    klass.enumerized_attributes.must_be_empty
    klass.enumerize(:foo, :in => %w[a b])
    klass.enumerized_attributes[:foo].must_be_instance_of Enumerize::Attribute
  end

  it "doesn't override existing method" do
    method = klass.method(:name)
    klass.enumerize(:name, :in => %w[a b], :default => 'a')
    klass.method(:name).must_equal method
  end

  it "inherits enumerized attributes from a parent class" do
    klass.enumerize(:foo, :in => %w[a b])
    subklass.enumerized_attributes[:foo].must_be_instance_of Enumerize::Attribute
  end

  it "inherits enumerized attributes from a grandparent class" do
    klass.enumerize(:foo, :in => %w[a b])
    Class.new(subklass).enumerized_attributes[:foo].must_be_instance_of Enumerize::Attribute
  end

  it "doesn't add enumerized attributes to parent class" do
    klass.enumerize(:foo, :in => %w[a b])
    subklass.enumerize(:bar, :in => %w[c d])

    klass.enumerized_attributes[:bar].must_equal nil
  end

  it 'adds new parent class attributes to subclass' do
    subklass = Class.new(klass)
    klass.enumerize :foo, :in => %w[a b]
    subklass.enumerized_attributes[:foo].must_be_instance_of Enumerize::Attribute
  end

  it 'stores nil value' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = nil
    object.instance_variable_get(:@foo).must_equal nil
  end

  it 'casts value to string for validation' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :c
    object.read_attribute_for_validation(:foo).must_equal 'c'
  end

  it "doesn't cast nil to string for validation" do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = nil
    object.read_attribute_for_validation(:foo).must_equal nil
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
    object.foo.must_be_nil
    object.attributes.must_equal({:foo => nil})

    object.foo = 'test'
    object.foo.must_equal 'test'
    object.attributes.must_equal(:foo => 'test')
  end

  it 'stores hash values' do
    klass.enumerize(:foo, :in => {:a => 1, :b => 2})

    object.foo = :a
    object.instance_variable_get(:@foo).must_equal 1
    object.foo.must_equal 'a'

    object.foo = :b
    object.instance_variable_get(:@foo).must_equal 2
    object.foo.must_equal 'b'
  end

  it 'returns custom value' do
    klass.enumerize(:foo, :in => {:a => 1, :b => 2})

    object.foo = :a
    object.foo_value.must_equal 1

    object.foo = :b
    object.foo_value.must_equal 2
  end
end
