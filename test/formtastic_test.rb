require 'test_helper'
require 'rails'

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

  class Thing < Struct.new(:name)
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def persisted?
      false
    end
  end

  class User < Struct.new(:sex, :age)
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    extend Enumerize

    enumerize :sex, :in => [:male, :female]

    def persisted?
      false
    end
  end

  class Post < Struct.new(:category, :title)
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    extend Enumerize

    enumerize :categories, :in => [:music, :games], :multiple => true

    def persisted?
      false
    end
  end

  before { $VERBOSE = nil }
  after  { $VERBOSE = true }

  let(:user) { User.new }
  let(:post) { Post.new }

  it 'renders select with enumerized values' do
    concat(semantic_form_for(user) do |f|
      f.input :sex
    end)

    assert_select 'select option[value=male]'
    assert_select 'select option[value=female]'
  end

  it 'renders multiple select with enumerized values' do
    concat(semantic_form_for(post) do |f|
      f.input(:categories)
    end)

    assert_select 'select[multiple=multiple]'
    assert_select 'select option[value=music]'
    assert_select 'select option[value=games]'
  end

  it 'renders multiple select with selected enumerized value' do
    post.categories << :music

    concat(semantic_form_for(post) do |f|
      f.input(:categories)
    end)

    assert_select 'select[multiple=multiple]'
    assert_select 'select option[value=music][selected=selected]'
    assert_select 'select option[value=games][selected=selected]', count: 0
  end

  it 'renders checkboxes with enumerized values' do
    concat(semantic_form_for(post) do |f|
      f.input(:categories, as: :check_boxes)
    end)

    assert_select 'select[multiple=multiple]', count: 0
    assert_select 'input[type=checkbox][value=music]'
    assert_select 'input[type=checkbox][value=games]'
  end

  it 'renders checkboxes with selected enumerized value' do
    post.categories << :music

    concat(semantic_form_for(post) do |f|
      f.input(:categories, as: :check_boxes)
    end)

    assert_select 'input[type=checkbox][value=music][checked=checked]'
    assert_select 'input[type=checkbox][value=games][checked=checked]', count: 0
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

  it 'does not affect not enumerized classes' do
    concat(semantic_form_for(Thing.new) do |f|
      f.input(:name)
    end)

    assert_select 'input[type=text]'
  end
end
