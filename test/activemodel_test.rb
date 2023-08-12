# frozen_string_literal: true

require 'test_helper'

if defined?(::ActiveModel::Attributes)

class ActiveModelTest < Minitest::Spec
  class ActiveModelUser
    include ActiveModel::Model
    include ActiveModel::Attributes
    extend Enumerize

    attribute :name, :string
    enumerize :sex, :in => %w[male female]
    enumerize :role, :in => %w[admin user], :default => 'user'
    enumerize :interests, :in => [:music, :sports, :dancing, :programming], :multiple => true
  end

  class InterestsRequiredActiveModelUser < ActiveModelUser
    validates :interests, presence: true
  end

  let(:model) { ActiveModelUser }

  it 'initialize value' do
    user = model.new(:name => 'active_model_user', :sex => :male, :role => :user, :interests => [:music, :programming])
    expect(user.sex).must_equal 'male'
    expect(user.sex_text).must_equal 'Male'
    expect(user.role).must_equal 'user'
    expect(user.role_text).must_equal 'User'
    expect(user.interests).must_equal %w(music programming)
  end

  it 'sets nil if invalid value is passed' do
    user = model.new
    user.sex = :invalid
    expect(user.sex).must_be_nil
  end

  it 'stores value' do
    user = model.new
    user.sex = :female
    expect(user.sex).must_equal 'female'
  end

  it 'has default value' do
    expect(model.new.role).must_equal 'user'
  end

  it 'validates inclusion' do
    user = model.new
    user.role = 'wrong'
    expect(user).wont_be :valid?
  end

  it 'supports multiple attributes' do
    user = ActiveModelUser.new
    expect(user.interests).must_be_instance_of Enumerize::Set
    expect(user.interests).must_be_empty
    user.interests << :music
    expect(user.interests).must_equal %w(music)
    user.interests << :sports
    expect(user.interests).must_equal %w(music sports)

    user.interests = []
    interests = user.interests
    interests << :music
    expect(interests).must_equal %w(music)
    interests << :dancing
    expect(interests).must_equal %w(music dancing)
  end

  it 'returns invalid multiple value for validation' do
    user = ActiveModelUser.new
    user.interests << :music
    user.interests << :invalid
    values = user.read_attribute_for_validation(:interests)
    expect(values).must_equal %w(music invalid)
  end

  it 'validates multiple attributes' do
    user = ActiveModelUser.new
    user.interests << :invalid
    expect(user).wont_be :valid?

    user.interests = Object.new
    expect(user).wont_be :valid?

    user.interests = ['music', '']
    expect(user).must_be :valid?
  end

  it 'validates presence with multiple attributes' do
    user = InterestsRequiredActiveModelUser.new
    user.interests = []
    user.valid?

    expect(user.errors[:interests]).wont_be :empty?

    user.interests = ['']
    user.valid?

    expect(user.errors[:interests]).wont_be :empty?

    user.interests = [:dancing, :programming]
    user.valid?

    expect(user.errors[:interests]).must_be_empty
  end
end

else
  # Skip
end
