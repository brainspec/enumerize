require 'test_helper'
require 'yaml'

describe Enumerize::Value do
  class Attr < Struct.new(:values)
  end

  let(:attr) { Attr.new([]) }
  let(:val)  { Enumerize::Value.new(attr, 'test_value', 1) }

  it 'is a string' do
    val.must_be_kind_of String
  end

  describe 'equality' do
    it 'is compared to string' do
      val.must_be :==, 'test_value'
      val.wont_be :==, 'not_value'
    end

    it 'is compared to symbol' do
      val.must_be :==, :test_value
      val.wont_be :==, :not_value
    end

    it 'is compared to integer' do
      val.must_be :==, 1
      val.wont_be :==, 2
    end
  end

  describe 'translation' do
    let(:attr)  { Struct.new(:values, :name, :i18n_scopes).new([], "attribute_name", []) }

    it 'uses common translation' do
      store_translations(:en, :enumerize => {:attribute_name => {:test_value => "Common translation"}}) do
        val.text.must_be :==, "Common translation"
      end
    end

    it 'uses default translation from the "default" section if its present' do
      store_translations(:en, :enumerize => {:defaults => {:attribute_name => {:test_value => "Common translation"}}}) do
        val.text.must_be :==, "Common translation"
      end
    end

    it 'uses model specific translation' do
      attr.i18n_scopes = ["enumerize.model_name.attribute_name"]

      store_translations(:en, :enumerize => {:model_name => {:attribute_name => {:test_value => "Model Specific translation"}}}) do
        val.text.must_be :==, "Model Specific translation"
      end
    end

    it 'uses model specific translation rather than common translation' do
      attr.i18n_scopes = ["enumerize.model_name.attribute_name"]

      store_translations(:en, :enumerize => {:attribute_name => {:test_value => "Common translation"}, :model_name => {:attribute_name => {:test_value => "Model Specific translation"}}}) do
        val.text.must_be :==, "Model Specific translation"
      end
    end

    it 'uses simply humanized value when translation is undefined' do
      store_translations(:en, :enumerize => {}) do
        val.text.must_be :==, "Test value"
      end
    end

    it 'uses specified in options translation scope' do
      attr.i18n_scopes = ["other.scope"]

      store_translations(:en, :other => {:scope => {:test_value => "Scope specific translation"}}) do
        val.text.must_be :==, "Scope specific translation"
      end
    end

    it 'uses first found translation scope from options' do
      attr.i18n_scopes = ["nonexistent.scope", "other.scope"]

      store_translations(:en, :other => {:scope => {:test_value => "Scope specific translation"}}) do
        val.text.must_be :==, "Scope specific translation"
      end
    end
  end

  describe 'boolean methods comparison' do
    before do
      attr.values = [val, Enumerize::Value.new(attr, 'other_value')]
    end

    it 'returns true if value equals method' do
      val.test_value?.must_equal true
    end

    it 'returns false if value does not equal method' do
      val.other_value?.must_equal false
    end

    it 'raises NoMethodError if there are no values like boolean method' do
      proc {
        val.some_method?
      }.must_raise NoMethodError
    end

    it 'raises ArgumentError if arguments are passed' do
      proc {
        val.other_value?('<3')
      }.must_raise ArgumentError
    end

    it 'responds to methods for existing values' do
      val.must_respond_to :test_value?
      val.must_respond_to :other_value?
    end

    it 'returns a method object' do
      val.method(:test_value?).must_be_instance_of Method
    end

    it "doesn't respond to a method for not existing value" do
      val.wont_respond_to :some_method?
    end
  end

  describe 'serialization' do
    let(:val) { Enumerize::Value.new(attr, 'test_value') }

    it 'should be serialized to yaml as string value' do
      assert_equal YAML.dump('test_value'), YAML.dump(val)
    end

    it 'serializes with Marshal' do
      dump_value = Marshal.dump(val)
      Marshal.load(dump_value).must_equal 'test_value'
    end
  end
end
