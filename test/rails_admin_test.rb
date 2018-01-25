require 'test_helper'

class RailsAdminSpec < MiniTest::Spec
  let(:kklass) do
    Class.new do
      extend Enumerize
    end
  end

  let(:object) { kklass.new }

  it 'defines enum method' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
      kklass.enumerize(:foo, in: [:a, :b])
      object.foo_enum.must_equal [['a text', 'a'], ['b text', 'b']]
    end
  end

  it 'defines enum properly for custom values enumerations' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
      kklass.enumerize(:foo, in: {:a => 1, :b => 2})
      object.foo_enum.must_equal [['a text', 'a'], ['b text', 'b']]
    end
  end
end
