# frozen_string_literal: true

require 'test_helper'
require 'yaml'

class ValueTest < Minitest::Spec
  class Model
  end

  class Attr < Struct.new(:values, :name, :i18n_scopes, :klass)
    def value?(value)
      values.include?(value)
    end
  end

  let(:attr) { Attr.new([], "attribute_name", [], Model) }
  let(:val) { Enumerize::Value.new(attr, 'test_value', 1) }

  it 'is a string' do
    expect(val).must_be_kind_of String
  end

  describe 'equality' do
    it 'is compared to string' do
      expect(val).must_be :==, 'test_value'
      expect(val).wont_be :==, 'not_value'
    end

    it 'is compared to symbol' do
      expect(val).must_be :==, :test_value
      expect(val).wont_be :==, :not_value
    end

    it 'is compared to integer' do
      expect(val).must_be :==, 1
      expect(val).wont_be :==, 2
    end
  end

  describe 'translation' do
    it 'uses common translation' do
      store_translations(:en, :enumerize => {:attribute_name => {:test_value => "Common translation"}}) do
        expect(val.text).must_be :==, "Common translation"
      end
    end

    it 'uses default translation from the "default" section if its present' do
      store_translations(:en, :enumerize => {:defaults => {:attribute_name => {:test_value => "Common translation"}}}) do
        expect(val.text).must_be :==, "Common translation"
      end
    end

    it 'uses model specific translation' do
      attr.i18n_scopes = ["enumerize.model_name.attribute_name"]

      store_translations(:en, :enumerize => {:model_name => {:attribute_name => {:test_value => "Model Specific translation"}}}) do
        expect(val.text).must_be :==, "Model Specific translation"
      end
    end

    it 'uses model specific translation rather than common translation' do
      attr.i18n_scopes = ["enumerize.model_name.attribute_name"]

      store_translations(:en, :enumerize => {:attribute_name => {:test_value => "Common translation"}, :model_name => {:attribute_name => {:test_value => "Model Specific translation"}}}) do
        expect(val.text).must_be :==, "Model Specific translation"
      end
    end

    it 'uses simply humanized value when translation is undefined' do
      store_translations(:en, :enumerize => {}) do
        expect(val.text).must_be :==, "Test value"
      end
    end

    it 'uses specified in options translation scope' do
      attr.i18n_scopes = ["other.scope"]

      store_translations(:en, :other => {:scope => {:test_value => "Scope specific translation"}}) do
        expect(val.text).must_be :==, "Scope specific translation"
      end
    end

    it 'uses first found translation scope from options' do
      attr.i18n_scopes = ["nonexistent.scope", "other.scope"]

      store_translations(:en, :other => {:scope => {:test_value => "Scope specific translation"}}) do
        expect(val.text).must_be :==, "Scope specific translation"
      end
    end

    it 'allows to pass a proc as i18n_scopes param' do
      attr.i18n_scopes = [proc { |v| "other.scope.#{v}" }]

      store_translations(:en, :other => {:scope => {:"1" => {:test_value => "Scope specific translation"}}}) do
        expect(val.text).must_be :==, "Scope specific translation"
      end
    end
  end

  describe 'boolean methods comparison' do
    before do
      attr.values = [val, Enumerize::Value.new(attr, 'other_value')]
    end

    it 'returns true if value equals method' do
      expect(val.test_value?).must_equal true
    end

    it 'returns false if value does not equal method' do
      expect(val.other_value?).must_equal false
    end

    it 'raises NoMethodError if there are no values like boolean method' do
      expect(proc {
        val.some_method?
      }).must_raise NoMethodError
    end

    it 'raises ArgumentError if arguments are passed' do
      expect(proc {
        val.other_value?('<3')
      }).must_raise ArgumentError
    end

    it 'responds to methods for existing values' do
      expect(val).must_respond_to :test_value?
      expect(val).must_respond_to :other_value?
    end

    it 'returns a method object' do
      expect(val.method(:test_value?)).must_be_instance_of Method
    end

    it "doesn't respond to a method for not existing value" do
      expect(val).wont_respond_to :some_method?
    end

    it "doesn't respond to methods is value was modified" do
      modified_value = val.upcase

      expect(modified_value.upcase).wont_respond_to :some_method?
      expect(modified_value.upcase).wont_respond_to :test_value?
      expect(modified_value.upcase).wont_respond_to :other_value?
    end
  end

  describe 'serialization' do
    let(:val) { Enumerize::Value.new(attr, 'test_value') }

    it 'should be serialized to yaml as string value' do
      assert_equal YAML.dump('test_value'), YAML.dump(val)
    end

    it 'serializes with Marshal' do
      dump_value = Marshal.dump(val)
      expect(Marshal.load(dump_value)).must_equal 'test_value'
    end
  end

  describe 'initialize' do
    it 'no output if undefined boolean method' do
      assert_silent() { Enumerize::Value.new(attr, 'test_value') }
    end
  end

  describe '#as_json' do
    it 'returns String object, not Value object' do
      expect(val.as_json.class).must_equal String
      expect(val.as_json).must_equal 'test_value'
    end
  end
end
