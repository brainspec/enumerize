require 'test_helper'

module Formtastic
  module Helpers
    module InputHelper
      remove_method :input_class
      def input_class(as)
        input_class_with_const_defined(as)
      end
    end
  end
end

class FormtasticSpec < MiniTest::Spec
  include ViewTestHelper
  include Formtastic::Helpers::FormHelper

  class User < Struct.new(:sex, :age)
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    include Enumerize

    enumerize :sex, :in => [:male, :female]

    def persisted?
      false
    end
  end

  before { $VERBOSE = nil }
  after  { $VERBOSE = true }

  let(:user) { User.new }

  it 'renders select with enumerized values' do
    concat(semantic_form_for(user) do |f|
      f.input :sex
    end)

    assert_select 'select option[value=male]'
    assert_select 'select option[value=female]'
  end

  it 'renders radio buttons with enumerized values' do
    concat(semantic_form_for(user) do |f|
      f.input :sex, :as => :radio
    end)

    assert_select 'input[type=radio][value=male]'
    assert_select 'input[type=radio][value=female]'
  end

  it 'does not affect not enumerized attributes' do
    concat(semantic_form_for(user) do |f|
      f.input(:age)
    end)

    assert_select 'input[type=text]'
  end
end
