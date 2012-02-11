require 'test_helper'

describe Enumerize::Integrations::Basic do
  let(:klass) do
    Class.new do
      include Enumerize
    end
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
    I18n.backend.store_translations(:en, :enumerize => {:foo => {:a => 'a text'}})
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    object.foo.text.must_equal 'a text'
    object.foo_text.must_equal 'a text'
  end

  it 'returns nil as translation when value is nil' do
    I18n.backend.store_translations(:en, :enumerize => {:foo => {:a => 'a text'}})
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo_text.must_equal nil
  end

  it 'scopes translation by i18 key' do
    I18n.backend.store_translations(:en, :enumerize => {:example_class => {:foo => {:a => 'a text scoped'}}})
    def klass.model_name
      name = "ExampleClass"
      def name.i18n_key
        'example_class'
      end

      name
    end
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    object.foo.text.must_equal 'a text scoped'
    object.foo_text.must_equal 'a text scoped'
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

  it 'raises exception on invalid default value' do
    proc {
      klass.enumerize(:foo, :in => [:a, :b], :default => :c)
    }.must_raise ArgumentError
  end

  describe 'delegated boolean methods' do
    it 'raise exception if boolean method is not delegated' do
      klass.enumerize(:foo, :in => [:a, :b])
      proc {
        object.a?
      }.must_raise NoMethodError
    end

    it 'raise exception if boolean method is not included in values' do
      klass.enumerize(:foo, :in => [:a, :b], :delegate => true)
      proc {
        object.c?
      }.must_raise NoMethodError
    end

    it 'returns true if value equals method name' do
      klass.enumerize(:foo, :in => [:a, :b], :delegate => true)
      object.foo = :a
      object.a?.must_equal true
    end

    it 'returns false if value do not equal method name' do
      klass.enumerize(:foo, :in => [:a, :b], :delegate => true)
      object.foo = :a
      object.b?.must_equal false
    end
  end
end
