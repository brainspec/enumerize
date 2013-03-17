require 'test_helper'
require 'active_record'
require 'logger'

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.string :sex
    t.string :role
    t.string :name
    t.string :interests
    t.string :status
  end
end

module RoleEnum
  extend Enumerize
  enumerize :role, :in => [:user, :admin], :default => :user, scope: :having_role
end

class User < ActiveRecord::Base
  extend Enumerize
  include RoleEnum

  enumerize :sex, :in => [:male, :female]

  serialize :interests, Array
  enumerize :interests, :in => [:music, :sports, :dancing, :programming], :multiple => true

  enumerize :status, :in => { active: 1, blocked: 2 }, scope: true
end

describe Enumerize::ActiveRecord do
  it 'sets nil if invalid value is passed' do
    user = User.new
    user.sex = :invalid
    user.sex.must_equal nil
  end

  it 'saves value' do
    User.delete_all
    user = User.new
    user.sex = :female
    user.save!
    user.sex.must_equal 'female'
  end

  it 'loads value' do
    User.delete_all
    User.create!(:sex => :male)
    store_translations(:en, :enumerize => {:sex => {:male => 'Male'}}) do
      user = User.first
      user.sex.must_equal 'male'
      user.sex_text.must_equal 'Male'
    end
  end

  it 'has default value' do
    User.new.role.must_equal 'user'
    User.new.attributes['role'].must_equal 'user'
  end

  it 'validates inclusion' do
    user = User.new
    user.role = 'wrong'
    user.wont_be :valid?
  end

  it 'validates inclusion on mass assignment' do
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(role: 'wrong')
    end
  end

  it "uses persisted value for validation if it hasn't been set" do
    user = User.create! :sex => :male
    User.find(user).read_attribute_for_validation(:sex).must_equal 'male'
  end

  it 'is valid with empty string assigned' do
    user = User.new
    user.role = ''
    user.must_be :valid?
  end

  it 'stores nil when empty string assigned' do
    user = User.new
    user.role = ''
    user.read_attribute(:role).must_equal nil
  end

  it 'supports multiple attributes' do
    user = User.new
    user.interests.must_be_empty
    user.interests << :music
    user.interests.must_equal %w(music)
    user.save!

    user = User.find(user.id)
    user.interests.must_be_instance_of Enumerize::Set
    user.interests.must_equal %w(music)
    user.interests << :sports
    user.interests.must_equal %w(music sports)

    user.interests = []
    interests = user.interests
    interests << :music
    interests.must_equal %w(music)
    interests << :dancing
    interests.must_equal %w(music dancing)
  end

  it 'returns invalid multiple value for validation' do
    user = User.new
    user.interests << :music
    user.interests << :invalid
    values = user.read_attribute_for_validation(:interests)
    values.must_equal %w(music invalid)
  end

  it 'validates multiple attributes' do
    user = User.new
    user.interests << :invalid
    user.wont_be :valid?

    user.interests = Object.new
    user.wont_be :valid?

    user.interests = ['music', '']
    user.must_be :valid?
  end

  it 'adds scope' do
    user_1 = User.create!(status: :active, role: :admin)
    user_2 = User.create!(status: :blocked)

    User.with_status(:active).must_equal [user_1]
    User.with_status(:blocked).must_equal [user_2]
    User.with_status(:active, :blocked).to_set.must_equal [user_1, user_2].to_set

    User.having_role(:admin).must_equal [user_1]
  end

  it 'allows either key or value as valid' do
    user_1 = User.new(status: :active)
    user_2 = User.new(status: 1)
    user_3 = User.new(status: '1')

    user_1.status.must_equal 'active'
    user_2.status.must_equal 'active'
    user_3.status.must_equal 'active'

    user_1.must_be :valid?
    user_2.must_be :valid?
    user_3.must_be :valid?
  end
end
