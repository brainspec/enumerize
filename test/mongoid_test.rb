require 'test_helper'

begin

silence_warnings do
  require 'mongoid'
end

Mongoid.configure do |config|
  config.connect_to('enumerize-test-suite')
  config.options = { use_utc: true, include_root_in_json: true }
end

describe Enumerize do
  class MongoidUser
    include Mongoid::Document
    extend Enumerize

    field :sex
    field :role
    enumerize :sex,    :in => %w[male female], scope: true
    enumerize :status, :in => %w[notice warning error], scope: true
    enumerize :role,   :in => %w[admin user], :default => 'user', scope: :having_role
    enumerize :mult,   :in => %w[one two three four], :multiple => true
  end

  before { $VERBOSE = nil }
  after  { $VERBOSE = true }

  let(:model) { MongoidUser }

  it 'sets nil if invalid value is passed' do
    user = model.new
    user.sex = :invalid
    user.sex.must_be_nil
  end

  it 'saves value' do
    model.delete_all
    user = model.new
    user.sex = :female
    user.save!
    user.sex.must_equal 'female'
  end

  it 'loads value' do
    model.delete_all
    model.create!(:sex => :male)
    store_translations(:en, :enumerize => {:sex => {:male => 'Male'}}) do
      user = model.first
      user.sex.must_equal 'male'
      user.sex_text.must_equal 'Male'
    end
  end

  it 'has default value' do
    model.new.role.must_equal 'user'
  end

  it 'uses after_initialize callback to set default value' do
    model.delete_all
    model.create!(sex: 'male', role: nil)

    user = model.where(sex: 'male').first
    user.role.must_equal 'user'
  end

  it 'does not set default value for not selected attributes' do
    model.delete_all
    model.create!(sex: :male)

    assert_equal ['_id'], model.only(:id).first.attributes.keys
  end

  it 'validates inclusion' do
    user = model.new
    user.role = 'wrong'
    user.wont_be :valid?
  end

  it 'assigns value on loaded record' do
    model.delete_all
    model.create!(:sex => :male)
    user = model.first
    user.sex = :female
    user.sex.must_equal 'female'
  end

  it 'loads multiple properly' do
    model.delete_all

    model.create!(:mult => ['one', 'two'])
    user = model.first
    user.mult.to_a.must_equal ['one', 'two']
  end

  it 'adds scope' do
    model.delete_all

    user_1 = model.create!(sex: :male, role: :admin)
    user_2 = model.create!(sex: :female, role: :user)

    model.with_sex(:male).to_a.must_equal [user_1]
    model.with_sex(:female).to_a.must_equal [user_2]
    model.with_sex(:male, :female).to_set.must_equal [user_1, user_2].to_set

    model.without_sex(:male).to_a.must_equal [user_2]
    model.without_sex(:female).to_a.must_equal [user_1]
    model.without_sex(:male, :female).to_a.must_equal []

    model.having_role(:admin).to_a.must_equal [user_1]
    model.having_role(:user).to_a.must_equal [user_2]
  end

  it 'chains scopes' do
    model.delete_all

    user_1 = model.create!(status: :notice)
    user_2 = model.create!(status: :warning)
    user_3 = model.create!(status: :error)

    model.with_status(:notice, :warning).with_status(:notice, :error).to_a.must_equal [user_1]
    model.with_status(:notice, :warning).union.with_status(:notice, :error).to_a.must_equal [user_1, user_2, user_3]
  end

  it 'ignores not enumerized values that passed to the scope method' do
    model.delete_all

    model.with_sex(:foo).must_equal []
  end
end

rescue LoadError
  # Skip
end
