require 'test_helper'
require 'simple_form/version'

class SimpleFormSpec < MiniTest::Spec
  include ViewTestHelper

  class User < Struct.new(:sex, :name)
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
    as = SimpleForm::VERSION > '2.0' ? :radio_buttons : :radio

    concat(simple_form_for(user) do |f|
      f.input(:sex, :as => as)
    end)

    assert_select 'input[type=radio][value=male]'
    assert_select 'input[type=radio][value=female]'
  end

  it 'does not affect not enumerized attributes' do
    concat(simple_form_for(user) do |f|
      f.input(:name)
    end)

    assert_select 'input.string'
  end
end
