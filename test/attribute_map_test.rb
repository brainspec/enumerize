# frozen_string_literal: true

require 'test_helper'

module Enumerize
  class AttributeMapTest < Minitest::Spec
    subject { AttributeMap.new }

    def make_attr(name)
      Attribute.new(nil, name, :in => %[a b])
    end

    it 'empty when no attrs' do
      expect(subject).must_be_empty
    end

    it 'not empty when attr added' do
      subject << make_attr(:a)
      expect(subject).wont_be_empty
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

      expect(count).must_equal 2
      expect(actual).must_equal [attr_1, attr_2]
    end

    it 'reads attribute by name' do
      attr = make_attr(:a)
      subject << attr
      expect(subject[:a]).must_equal attr
    end

    it 'reads attribute by name using string' do
      attr = make_attr(:a)
      subject << attr
      expect(subject['a']).must_equal attr
    end

    it 'updates dependants' do
      attr = make_attr(:a)
      dependant = Minitest::Mock.new
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
      expect(dependant[:a]).must_equal attr
    end
  end
end
