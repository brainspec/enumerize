# frozen_string_literal: true

require 'test_helper'

begin

silence_warnings do
  require 'mongoid'
end

Mongoid.configure do |config|
  config.connect_to('enumerize-test-suite')
  config.options = { use_utc: true, include_root_in_json: true }
end

class MongoidTest < Minitest::Spec
  class MongoidUser
    include Mongoid::Document
    extend Enumerize

    field :sex
    field :role
    field :foo
    field :skill

    enumerize :sex,    :in => %w[male female], scope: true
    enumerize :status, :in => %w[notice warning error], scope: true
    enumerize :role,   :in => %w[admin user], :default => 'user', scope: :having_role
    enumerize :mult,   :in => %w[one two three four], :multiple => true
    enumerize :foo,    :in => %w[bar baz], :skip_validations => true
    enumerize :skill,  :in => { noob: 0, casual: 1, pro: 2 }, scope: :shallow
    enumerize :account_type, :in => %w[basic premium], scope: :shallow
  end

  before { $VERBOSE = nil }
  after  { $VERBOSE = true }

  let(:model) { MongoidUser }

  it 'sets nil if invalid value is passed' do
    user = model.new
    user.sex = :invalid
    expect(user.sex).must_be_nil
  end

  it 'saves value' do
    model.delete_all
    user = model.new
    user.sex = :female
    user.save!
    expect(user.sex).must_equal 'female'
  end

  it 'loads value' do
    model.delete_all
    model.create!(:sex => :male)
    store_translations(:en, :enumerize => {:sex => {:male => 'Male'}}) do
      user = model.first
      expect(user.sex).must_equal 'male'
      expect(user.sex_text).must_equal 'Male'
    end
  end

  it 'has default value' do
    expect(model.new.role).must_equal 'user'
  end

  it 'uses after_initialize callback to set default value' do
    model.delete_all
    model.create!(sex: 'male', role: nil)

    user = model.where(sex: 'male').first
    expect(user.role).must_equal 'user'
  end

  it 'does not set default value for not selected attributes' do
    model.delete_all
    model.create!(sex: :male)

    assert_equal ['_id'], model.only(:id).first.attributes.keys
  end

  it 'validates inclusion' do
    user = model.new
    user.role = 'wrong'
    expect(user).wont_be :valid?
  end

  it 'does not validate inclusion when :skip_validations option passed' do
    user = model.new
    user.foo = 'wrong'
    expect(user).must_be :valid?
  end

  it 'sets value to enumerized field from db when record is reloaded' do
    user = model.create!(mult: [:one])
    model.find(user.id).update(mult: %i[two three])
    expect(user.mult).must_equal %w[one]
    user.reload
    expect(user.mult).must_equal %w[two three]
  end

  it 'assigns value on loaded record' do
    model.delete_all
    model.create!(:sex => :male)
    user = model.first
    user.sex = :female
    expect(user.sex).must_equal 'female'
  end

  it 'loads multiple properly' do
    model.delete_all

    model.create!(:mult => ['one', 'two'])
    user = model.first
    expect(user.mult.to_a).must_equal ['one', 'two']
  end

  it 'adds scope' do
    model.delete_all

    user_1 = model.create!(sex: :male, skill: :noob, role: :admin, account_type: :basic)
    user_2 = model.create!(sex: :female, skill: :noob, role: :user, account_type: :basic)
    user_3 = model.create!(skill: :pro, account_type: :premium)

    expect(model.with_sex(:male).to_a).must_equal [user_1]
    expect(model.with_sex(:female).to_a).must_equal [user_2]
    expect(model.with_sex(:male, :female).to_set).must_equal [user_1, user_2].to_set

    expect(model.without_sex(:male).to_set).must_equal [user_2, user_3].to_set
    expect(model.without_sex(:female).to_set).must_equal [user_1, user_3].to_set
    expect(model.without_sex(:male, :female).to_a).must_equal [user_3]

    expect(model.having_role(:admin).to_a).must_equal [user_1]
    expect(model.having_role(:user).to_a).must_equal [user_2, user_3]

    expect(model.pro.to_a).must_equal [user_3]
    expect(model.premium.to_a).must_equal [user_3]

    expect(model.not_pro.to_set).must_equal [user_1, user_2].to_set
    expect(model.not_premium.to_set).must_equal [user_1, user_2].to_set
  end

  it 'chains scopes' do
    model.delete_all

    user_1 = model.create!(status: :notice)
    user_2 = model.create!(status: :warning)
    user_3 = model.create!(status: :error)

    expect(model.with_status(:notice, :warning).with_status(:notice, :error).to_a).must_equal [user_1]
    expect(model.with_status(:notice, :warning).union.with_status(:notice, :error).to_a).must_equal [user_1, user_2, user_3]
  end

  it 'ignores not enumerized values that passed to the scope method' do
    model.delete_all

    expect(model.with_sex(:foo)).must_equal []
  end
end

rescue LoadError
  # Skip
end
