# frozen_string_literal: true

require 'test_helper'

class ModuleAttributesSpec < Minitest::Spec
  it 'inherits attribute from the module' do
    mod = Module.new do
      extend Enumerize
      enumerize :sex, :in => %w[male female], :default => 'male'
    end

    klass = Class.new
    klass.send :include, mod
    expect(klass.enumerized_attributes[:sex]).must_be_instance_of Enumerize::Attribute
    expect(klass.new.sex).must_equal 'male'
    expect(klass.sex).must_be_instance_of Enumerize::Attribute
  end

  it 'uses new attributes from the module' do
    mod = Module.new do
      extend Enumerize
    end

    klass = Class.new
    klass.send :include, mod
    mod.enumerize :sex, :in => %w[male female], :default => 'male'
    expect(klass.enumerized_attributes[:sex]).must_be_instance_of Enumerize::Attribute
    expect(klass.new.sex).must_equal 'male'
    expect(klass.sex).must_be_instance_of Enumerize::Attribute
  end

  it 'validates attributes' do
    mod = Module.new do
      extend Enumerize
      enumerize :sex, :in => %w[male female]
    end

    klass = Class.new do
      include ActiveModel::Validations
      include mod

      def self.model_name
        ActiveModel::Name.new(self, nil, 'name')
      end
    end

    object = klass.new
    object.sex = 'wrong'
    expect(object).wont_be :valid?
    expect(object.errors[:sex]).must_include 'is not included in the list'
  end
end
