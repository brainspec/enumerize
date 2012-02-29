require 'test_helper'

describe 'SimpleForm hook' do
  include ViewTestHelper

  let(:user) { User.new }

  it 'renders select with enumerized values' do
    concat(simple_form_for(user) do |f|
      f.input(:sex, :as => :select)
    end)

    assert_select 'select option[value=male]', 'Male'
    assert_select 'select option[value=female]', 'Female'
  end

  it 'renders radio buttons with enumerated values' do
    concat(simple_form_for(user) do |f|
      f.input(:sex, :as => :radio_buttons)
    end)

    assert_select 'input[type=radio][value=male]'
    assert_select 'input[type=radio][value=female]'
  end
end
