# frozen_string_literal: true

require 'test_helper'
require 'sequel'
require 'logger'
require 'jdbc/sqlite3' if RUBY_PLATFORM == 'java'

class SequelTest < MiniTest::Spec
  silence_warnings do
    DB = if RUBY_PLATFORM == 'java'
      Sequel.connect('jdbc:sqlite::memory:')
    else
      Sequel.sqlite
    end
    DB.loggers << Logger.new(nil)
  end

  DB.create_table :users do
    primary_key :id
    String :sex
    String :role
    String :lambda_role
    String :name
    String :interests
    String :status
    Integer :skill
    String :account_type, default: "basic"
    String :foo
  end

  DB.create_table :documents do
    primary_key :id
    String :visibility
    Time :created_at
    Time :updated_at
  end

  class Document < Sequel::Model
    plugin :enumerize
    enumerize :visibility, :in => [:public, :private, :protected], :scope => true, :default => :public
  end

  module RoleEnum
    extend Enumerize
    enumerize :role, :in => [:user, :admin], :default => :user, scope: :having_role
    enumerize :lambda_role, :in => [:user, :admin], :default => lambda { :admin }
  end

  class User < Sequel::Model
    plugin :serialization, :json, :interests
    plugin :dirty
    plugin :defaults_setter
    plugin :validation_helpers
    plugin :enumerize
    include RoleEnum

    enumerize :sex, :in => [:male, :female], scope: :shallow

    enumerize :interests, :in => [:music, :sports, :dancing, :programming], :multiple => true

    enumerize :status, :in => { active: 1, blocked: 2 }, scope: true

    enumerize :skill, :in => { noob: 0, casual: 1, pro: 2 }, scope: :shallow

    enumerize :account_type, :in => [:basic, :premium]
  end

  class UniqStatusUser < User
    def validate
      super
      validates_unique :status
      validates_presence :sex
    end
  end

  class SkipValidationsUser < Sequel::Model(:users)
    include SkipValidationsEnum
  end

  class DoNotSkipValidationsUser < Sequel::Model(:users)
    include DoNotSkipValidationsEnum
  end

  class SkipValidationsLambdaUser < Sequel::Model(:users)
    include SkipValidationsLambdaEnum
  end

  class SkipValidationsLambdaWithParamUser < Sequel::Model(:users)
    include SkipValidationsLambdaWithParamEnum
  end

  it 'sets nil if invalid value is passed' do
    user = User.new
    user.sex = :invalid
    expect(user.sex).must_be_nil
  end

  it 'saves value' do
    User.filter{ true }.delete
    user = User.new
    user.sex = :female
    user.save
    expect(user.sex).must_equal 'female'
  end

  it 'loads value' do
    User.filter{ true }.delete
    User.create(:sex => :male)
    store_translations(:en, :enumerize => {:sex => {:male => 'Male'}}) do
      user = User.first
      expect(user.sex).must_equal 'male'
      expect(user.sex_text).must_equal 'Male'
    end
  end

  it 'has default value' do
    expect(User.new.role).must_equal 'user'
    expect(User.new.values[:role]).must_equal 'user'
  end

  it 'does not set default value for not selected attributes' do
    User.filter{ true }.delete
    User.create(:sex => :male)

    assert_equal [:id], User.select(:id).first.values.keys
  end

  it 'has default value with lambda' do
    expect(User.new.lambda_role).must_equal 'admin'
    expect(User.new.values[:lambda_role]).must_equal 'admin'
  end
  it 'uses after_initialize callback to set default value' do
    User.filter{ true }.delete
    User.create(sex: 'male', lambda_role: nil)

    user = User.where(:sex => 'male').first
    expect(user.lambda_role).must_equal 'admin'
  end

  it 'uses default value from db column' do
    expect(User.new.account_type).must_equal 'basic'
  end

  it 'validates inclusion' do
    user = User.new
    user.role = 'wrong'
    expect(user).wont_be :valid?
    expect(user.errors[:role]).must_include 'is not included in the list'
  end

  it 'validates inclusion on mass assignment' do
    assert_raises Sequel::ValidationFailed do
      User.create(role: 'wrong')
    end
  end

  it "uses persisted value for validation if it hasn't been set" do
    user = User.create :sex => :male
    expect(User[user.id].read_attribute_for_validation(:sex)).must_equal 'male'
  end

  it 'is valid with empty string assigned' do
    user = User.new
    user.role = ''
    expect(user).must_be :valid?
  end

  it 'stores nil when empty string assigned' do
    user = User.new
    user.role = ''
    expect(user.values[:role]).must_be_nil
  end

  it 'validates inclusion when :skip_validations = false' do
    user = DoNotSkipValidationsUser.new
    user.foo = 'wrong'
    expect(user).wont_be :valid?
    expect(user.errors[:foo]).must_include 'is not included in the list'
  end

  it 'does not validate inclusion when :skip_validations = true' do
    user = SkipValidationsUser.new
    user.foo = 'wrong'
    expect(user).must_be :valid?
  end

  it 'supports :skip_validations option as lambda' do
    user = SkipValidationsLambdaUser.new
    user.foo = 'wrong'
    expect(user).must_be :valid?
  end

  it 'supports :skip_validations option as lambda with a parameter' do
    user = SkipValidationsLambdaWithParamUser.new
    user.foo = 'wrong'
    expect(user).must_be :valid?
  end

  it 'supports multiple attributes' do
    user = User.new
    user.interests ||= []
    expect(user.interests).must_be_empty
    user.interests << "music"
    expect(user.interests).must_equal %w(music)
    user.save

    user = User[user.id]
    expect(user.interests).must_be_instance_of Enumerize::Set
    expect(user.interests).must_equal %w(music)
    user.interests << "sports"
    expect(user.interests).must_equal %w(music sports)

    user.interests = []
    interests = user.interests
    interests << "music"
    expect(interests).must_equal %w(music)
    interests << "dancing"
    expect(interests).must_equal %w(music dancing)
  end

  it 'returns invalid multiple value for validation' do
    user = User.new
    user.interests << :music
    user.interests << :invalid
    values = user.read_attribute_for_validation(:interests)
    expect(values).must_equal %w(music invalid)
  end

  it 'validates multiple attributes' do
    user = User.new
    user.interests << :invalid
    expect(user).wont_be :valid?

    user.interests = Object.new
    expect(user).wont_be :valid?

    user.interests = ['music', '']
    expect(user).must_be :valid?
  end

  it 'stores custom values for multiple attributes' do
    User.filter{ true }.delete

    klass = Class.new(User)
    klass.enumerize :interests, in: { music: 0, sports: 1, dancing: 2, programming: 3}, multiple: true

    user = klass.new
    user.interests << :music
    expect(user.interests).must_equal %w(music)
    user.save

    user = klass[user.id]
    expect(user.interests).must_equal %w(music)
  end

  it 'adds scope' do
    User.filter{ true }.delete

    user_1 = User.create(sex: :female, skill: :noob, status: :active, role: :admin)
    user_2 = User.create(sex: :female, skill: :casual, status: :blocked)
    user_3 = User.create(sex: :male, skill: :pro)

    expect(User.with_status(:active).to_a).must_equal [user_1]
    expect(User.with_status(:blocked).to_a).must_equal [user_2]
    expect(User.with_status(:active, :blocked).to_set).must_equal [user_1, user_2].to_set

    expect(User.without_status(:active).to_a).must_equal [user_2]
    expect(User.without_status(:active, :blocked).to_a).must_equal []

    expect(User.having_role(:admin).to_a).must_equal [user_1]
    expect(User.male.to_a).must_equal [user_3]
    expect(User.pro.to_a).must_equal [user_3]

    expect(User.not_male.to_set).must_equal [user_1, user_2].to_set
    expect(User.not_pro.to_set).must_equal [user_1, user_2].to_set
  end

  it 'allows either key or value as valid' do
    user_1 = User.new(status: :active)
    user_2 = User.new(status: 1)
    user_3 = User.new(status: '1')

    expect(user_1.status).must_equal 'active'
    expect(user_2.status).must_equal 'active'
    expect(user_3.status).must_equal 'active'

    expect(user_1).must_be :valid?
    expect(user_2).must_be :valid?
    expect(user_3).must_be :valid?
  end

  it 'supports defining enumerized attributes on abstract class' do
    Document.filter{ true }.delete

    document = Document.new
    document.visibility = :protected
    expect(document.visibility).must_equal 'protected'
  end

  it 'supports defining enumerized scopes on abstract class' do
    Document.filter{ true }.delete

    document_1 = Document.create(visibility: :public)
    document_2 = Document.create(visibility: :private)

    expect(Document.with_visibility(:public).to_a).must_equal [document_1]
  end

  it 'validates uniqueness' do
    user = User.create(status: :active, sex: "male")

    user = UniqStatusUser.new
    user.sex = "male"
    user.status = :active
    expect(user.valid?).must_equal false

    expect(user.errors[:status]).wont_be :empty?
  end

  it "doesn't update record" do
    Document.filter{ true }.delete

    expected = Time.new(2010, 10, 10)

    document = Document.new
    document.updated_at = expected
    document.save

    document = Document.last
    document.save

    assert_equal expected, document.updated_at
  end

  it 'changes from dirty should be serialized as scalar values' do
    user = User.create(:status => :active)
    user.status = :blocked

    expected = { status: [1, 2] }.to_yaml
    assert_equal expected, user.column_changes.to_yaml
  end
end
