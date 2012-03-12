require 'test_helper'

class ModuleAttributesSpec < MiniTest::Spec
  it 'inherits attribute from the module' do
    mod = Module.new do
      include Enumerize
      enumerize :sex, :in => %w[male female]
    end

    klass = Class.new
    klass.send :include, mod
    klass.enumerized_attributes[:sex].must_be_instance_of Enumerize::Attribute
  end

  it 'uses new attributes from the module' do
    mod = Module.new do
      include Enumerize
    end

    klass = Class.new
    klass.send :include, mod
    mod.enumerize :sex, :in => %w[male female]
    klass.enumerized_attributes[:sex].must_be_instance_of Enumerize::Attribute
  end
end
