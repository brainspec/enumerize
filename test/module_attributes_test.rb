require 'test_helper'

class ModuleAttributesSpec < MiniTest::Spec
  it 'inherits attribute from the module' do
    mod = Module.new do
      include Enumerize
      enumerize :sex, :in => %w[male female], :default => 'male'
    end

    klass = Class.new
    klass.send :include, mod
    klass.enumerized_attributes[:sex].must_be_instance_of Enumerize::Attribute
    klass.new.sex.must_equal 'male'
    klass.sex.must_be_instance_of Enumerize::Attribute
  end

  it 'uses new attributes from the module' do
    mod = Module.new do
      include Enumerize
    end

    klass = Class.new
    klass.send :include, mod
    mod.enumerize :sex, :in => %w[male female], :default => 'male'
    klass.enumerized_attributes[:sex].must_be_instance_of Enumerize::Attribute
    klass.new.sex.must_equal 'male'
    klass.sex.must_be_instance_of Enumerize::Attribute
  end
end
