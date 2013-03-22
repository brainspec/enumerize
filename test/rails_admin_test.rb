require 'test_helper'

class RailsAdminSpec < MiniTest::Spec
  let(:klass) do
    Class.new do
      extend Enumerize
    end
  end

  let(:object) { klass.new }

  it 'defines enum method' do
    store_translations(:en, :enumerize => {:foo => {:a => 'a text', :b => 'b text'}}) do
      klass.enumerize(:foo, in: [:a, :b])
      object.foo_enum.must_equal [['a text', 'a'], ['b text', 'b']]
    end
  end
end
