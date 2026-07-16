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

  # No plain `attribute` is declared before `enumerize` here. On Rails 8.1 the
  # ActiveModel-generated attribute-method module then outranks enumerize's own
  # reader module in the ancestor chain, so reads resolve through the type's
  # #cast. This model reproduces the raw-value regression that #cast fixes.
  class CastActiveModelUser
    include ActiveModel::Model
    include ActiveModel::Attributes
    extend Enumerize

    enumerize :sex, :in => %w[male female]
    enumerize :role, :in => %w[admin user], :default => 'user'
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

  describe 'Type#deserialize' do
    it 'deserializes single value' do
      type = model.attribute_types['sex']
      result = type.deserialize('male')
      expect(result).must_be_instance_of Enumerize::Value
      expect(result.to_s).must_equal 'male'
    end

    it 'returns nil for nil single value' do
      type = model.attribute_types['sex']
      result = type.deserialize(nil)
      expect(result).must_be_nil
    end

    it 'returns nil for invalid single value' do
      type = model.attribute_types['sex']
      result = type.deserialize('invalid')
      expect(result).must_be_nil
    end

    it 'treats array as invalid for non-multiple attribute' do
      type = model.attribute_types['sex']
      result = type.deserialize(['male', 'female'])
      expect(result).must_be_nil
    end

    it 'deserializes array of valid values for multiple attribute' do
      type = model.attribute_types['interests']
      result = type.deserialize(['music', 'sports'])
      expect(result).must_be_instance_of Array
      expect(result.map(&:to_s)).must_equal ['music', 'sports']
    end

    it 'deserializes empty array for multiple attribute' do
      type = model.attribute_types['interests']
      result = type.deserialize([])
      expect(result).must_equal []
    end

    it 'filters out invalid values from array' do
      type = model.attribute_types['interests']
      result = type.deserialize(['music', 'invalid', 'sports'])
      expect(result.map(&:to_s)).must_equal ['music', 'sports']
    end

    it 'returns nil for nil array value' do
      type = model.attribute_types['interests']
      result = type.deserialize(nil)
      expect(result).must_be_nil
    end

    it 'preserves values through serialize/deserialize cycle for single value' do
      type = model.attribute_types['sex']
      user = model.new(sex: 'female')

      serialized = type.serialize(user.sex)
      expect(serialized).must_equal 'female'

      deserialized = type.deserialize(serialized)
      expect(deserialized.to_s).must_equal 'female'
    end

    it 'preserves values through serialize/deserialize cycle for multiple values' do
      type = model.attribute_types['interests']
      user = model.new(interests: ['music', 'programming'])

      # Serialize the entire set
      serialized = user.interests.map { |v| type.serialize(v) }
      expect(serialized).must_equal ['music', 'programming']

      # Deserialize back
      deserialized = type.deserialize(serialized)
      expect(deserialized.map(&:to_s)).must_equal ['music', 'programming']
    end
  end

  describe 'Type#cast' do
    it 'casts single valid value to Enumerize::Value' do
      type = model.attribute_types['sex']
      result = type.cast('male')
      expect(result).must_be_instance_of Enumerize::Value
      expect(result.to_s).must_equal 'male'
    end

    it 'returns nil for nil single value' do
      type = model.attribute_types['sex']
      result = type.cast(nil)
      expect(result).must_be_nil
    end

    it 'returns original value for invalid single value' do
      type = model.attribute_types['sex']
      result = type.cast('invalid')
      expect(result).must_equal 'invalid'
    end

    it 'casts array of valid values for multiple attribute' do
      type = model.attribute_types['interests']
      result = type.cast(['music', 'sports'])
      expect(result).must_be_instance_of Array
      expect(result.map(&:to_s)).must_equal ['music', 'sports']
    end

    it 'returns empty array as-is for multiple attribute' do
      type = model.attribute_types['interests']
      result = type.cast([])
      expect(result).must_equal []
    end

    it 'filters out invalid values when at least one is valid' do
      type = model.attribute_types['interests']
      result = type.cast(['music', 'invalid', 'sports'])
      expect(result.map(&:to_s)).must_equal ['music', 'sports']
    end

    it 'returns array as-is when all values are invalid for multiple attribute' do
      type = model.attribute_types['interests']
      result = type.cast(['invalid1', 'invalid2'])
      expect(result).must_equal ['invalid1', 'invalid2']
    end

    it 'returns nil for nil value on multiple attribute' do
      type = model.attribute_types['interests']
      result = type.cast(nil)
      expect(result).must_be_nil
    end
  end

  describe 'Type#cast (model reader)' do
    # Regression coverage for the Rails 8.1 attribute-method module ordering
    # change: when no plain `attribute` precedes `enumerize`, the generated
    # reader outranks enumerize's module, so reads go through #cast and must
    # still return an Enumerize::Value. Without the #cast override the first
    # two examples fail on Rails 8.1 (raw String/Symbol instead of a value).
    it 'wraps a user-assigned value so predicate methods work' do
      user = CastActiveModelUser.new(sex: 'male')
      expect(user.sex).must_be_instance_of Enumerize::Value
      expect(user.sex.male?).must_equal true
      expect(user.sex.female?).must_equal false
    end

    it 'wraps a value assigned after initialization' do
      user = CastActiveModelUser.new
      user.sex = :female
      expect(user.sex).must_be_instance_of Enumerize::Value
      expect(user.sex.female?).must_equal true
    end

    it 'wraps the default value' do
      user = CastActiveModelUser.new
      expect(user.role).must_be_instance_of Enumerize::Value
      expect(user.role.user?).must_equal true
    end

    it 'returns nil when nil is assigned' do
      user = CastActiveModelUser.new(sex: 'male')
      user.sex = nil
      expect(user.sex).must_be_nil
    end

    it 'keeps an invalid value assignable so inclusion validation still rejects it' do
      # The reader's return for an invalid value is ordering-dependent (nil when
      # enumerize's writer wins on Rails <= 8.0, the raw value when the generated
      # reader wins on Rails 8.1); the portable guarantee is that validation fails.
      user = CastActiveModelUser.new(sex: 'invalid')
      expect(user).wont_be :valid?
      expect(user.errors[:sex]).wont_be :empty?
    end

    it 'leaves multiple: true attributes as an unmangled Enumerize::Set' do
      user = ActiveModelUser.new(interests: [:music, :programming])
      expect(user.interests).must_be_instance_of Enumerize::Set
      expect(user.interests.to_a).must_equal %w[music programming]
    end
  end
end

else
  # Skip
end
