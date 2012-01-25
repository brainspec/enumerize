require 'test_helper'
require 'syck'

describe Enumerize do
  let(:klass) do
    Class.new do
      include Enumerize
    end
  end

  let(:object) { klass.new }

  it 'defines method that returns nil' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo.must_equal nil
  end

  it 'defines setter method' do
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

  it 'returns options for select' do
    I18n.backend.store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}})
    klass.enumerize(:foo, :in => [:a, :b])
    klass.foo.options.must_equal [['a text', 'a'], ['b text', 'b']]
  end

  it 'dumpes value to yaml using' do
    klass.enumerize(:foo, :in => [:a, :b])
    object.foo = :a
    YAML.dump(object.foo).must_equal YAML.dump('a')
  end
end
