require 'test_helper'
require 'simple_form/version'

class SimpleFormSpec < MiniTest::Spec
  include ViewTestHelper
  include SimpleForm::ActionViewExtensions::FormHelper

  class User < Struct.new(:sex, :age)
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    include Enumerize

    enumerize :sex, :in => [:male, :female]

    def persisted?
      false
    end
  end

  let(:user) { User.new }

  it 'renders select with enumerized values' do
    concat(simple_form_for(user) do |f|
      f.input(:sex)
    end)

    assert_select 'select option[value=male]'
    assert_select 'select option[value=female]'
  end

  it 'renders radio buttons with enumerated values' do
    concat(simple_form_for(user) do |f|
      f.input(:sex, :as => :radio_buttons)
    end)

    assert_select 'input[type=radio][value=male]'
    assert_select 'input[type=radio][value=female]'
  end

  it 'does not affect not enumerized attributes' do
    concat(simple_form_for(user) do |f|
      f.input(:age)
    end)

    assert_select 'input.string'
  end
end
