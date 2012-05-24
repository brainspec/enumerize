require 'test_helper'

module Enumerize
  class AttributeMapTest < MiniTest::Spec
    subject { AttributeMap.new }

    def make_attr(name)
      Attribute.new(nil, name, :in => %[a b])
    end

    it 'empty when no attrs' do
      subject.must_be_empty
    end

    it 'not empty when attr added' do
      subject << make_attr(:a)
      subject.wont_be_empty
    end

    it 'iterates over added attrs' do
      attr_1 = make_attr(:a)
      attr_2 = make_attr(:b)

      subject << attr_1
      subject << attr_2

      count  = 0
      actual = []

      subject.each do |element|
        count += 1
        actual << element
      end

      count.must_equal 2
      actual.must_equal [attr_1, attr_2]
    end

    it 'reads attribute by name' do
      attr = make_attr(:a)
      subject << attr
      subject[:a].must_equal attr
    end

    it 'reads attribute by name using string' do
      attr = make_attr(:a)
      subject << attr
      subject['a'].must_equal attr
    end

    it 'updates dependants' do
      attr = make_attr(:a)
      dependant = MiniTest::Mock.new
      dependant.expect(:<<, nil, [attr])
      subject.add_dependant dependant
      subject << attr
      dependant.verify
    end

    it 'adds attrs to dependant' do
      attr = make_attr(:a)
      subject << attr
      dependant = AttributeMap.new
      subject.add_dependant dependant
      dependant[:a].must_equal attr
    end
  end
end
