# frozen_string_literal: true

require 'test_helper'
require 'active_record'
require 'logger'

db = (ENV['DB'] || 'sqlite3').to_sym

silence_warnings do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.configurations = {
    'sqlite3' => {
      'adapter' => 'sqlite3',
      'database' => ':memory:'
    },
    'postgresql' => {
      'adapter' => 'postgresql',
      'username' => ENV['DB_USER'],
      'password' => ENV['DB_PASSD'],
      'database' => 'enumerize_test'
    },
    'postgresql_master' => {
      'adapter' => 'postgresql',
      'username' => ENV['DB_USER'],
      'password' => ENV['DB_PASS'],
      'database' => 'template1',
      'schema_search_path' => 'public'
    }
  }
  if db == :postgresql
    ActiveRecord::Base.establish_connection(:postgresql_master)
    ActiveRecord::Base.connection.recreate_database('enumerize_test')
  end

  ActiveRecord::Base.establish_connection(db)
end

ActiveRecord::Base.connection.instance_eval do
  create_table :users do |t|
    t.string :sex
    t.string :role
    t.string :lambda_role
    t.string :name
    t.string :interests
    t.integer :status
    t.string :account_type, :default => :basic
  end

  create_table :documents do |t|
    t.integer :user_id
    t.string :visibility
    t.integer :status
    t.timestamps null: true
  end
end

class BaseEntity < ActiveRecord::Base
  self.abstract_class = true

  extend Enumerize
  enumerize :visibility, :in => [:public, :private, :protected], :scope => true, :default => :public
end

class Document < BaseEntity
  belongs_to :user

  enumerize :status, in: {draft: 1, release: 2}
end

module RoleEnum
  extend Enumerize
  enumerize :role, :in => [:user, :admin], :default => :user, scope: :having_role
  enumerize :lambda_role, :in => [:user, :admin], :default => lambda { :admin }
end

class User < ActiveRecord::Base
  extend Enumerize
  include RoleEnum

  enumerize :sex, :in => [:male, :female]

  serialize :interests, Array
  enumerize :interests, :in => [:music, :sports, :dancing, :programming], :multiple => true

  enumerize :status, :in => { active: 1, blocked: 2 }, scope: true

  enumerize :account_type, :in => [:basic, :premium]

  # There is no column for relationship enumeration for testing purposes: model
  # should not be broken even if the associated column does not exist yet.
  enumerize :relationship, :in => [:single, :married]

  has_many :documents
end

class UniqStatusUser < User
  validates :status, uniqueness: true
  validates :sex, presence: true
end

class InterestsRequiredUser < User
  validates :interests, presence: true
end

describe Enumerize::ActiveRecordSupport do
  it 'sets nil if invalid value is passed' do
    user = User.new
    user.sex = :invalid
    user.sex.must_be_nil
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

  it 'does not set default value for not selected attributes' do
    User.delete_all
    User.create!(:sex => :male)

    assert_equal ['id'], User.select(:id).first.attributes.keys
  end

  it 'has default value with lambda' do
    User.new.lambda_role.must_equal 'admin'
    User.new.attributes['lambda_role'].must_equal 'admin'
  end

  it 'uses after_initialize callback to set default value' do
    User.delete_all
    User.create!(sex: 'male', lambda_role: nil)

    user = User.where(:sex => 'male').first
    user.lambda_role.must_equal 'admin'
  end

  it 'uses default value from db column' do
    User.new.account_type.must_equal 'basic'
  end

  it 'has default value with default scope' do
    UserWithDefaultScope = Class.new(User) do
      default_scope -> { having_role(:user) }
    end

    UserWithDefaultScope.new.role.must_equal 'user'
    UserWithDefaultScope.new.attributes['role'].must_equal 'user'
  end

  it 'validates inclusion' do
    user = User.new
    user.role = 'wrong'
    user.wont_be :valid?
    user.errors[:role].must_include 'is not included in the list'
  end

  it 'validates inclusion when using write_attribute with string attribute' do
    user = User.new
    user.send(:write_attribute, 'role', 'wrong')
    user.read_attribute_for_validation(:role).must_equal 'wrong'
    user.wont_be :valid?
    user.errors[:role].must_include 'is not included in the list'
  end

  it 'validates inclusion when using write_attribute with symbol attribute' do
    user = User.new
    user.send(:write_attribute, :role, 'wrong')
    user.read_attribute_for_validation(:role).must_equal 'wrong'
    user.wont_be :valid?
    user.errors[:role].must_include 'is not included in the list'
  end

  it 'validates inclusion on mass assignment' do
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(role: 'wrong')
    end
  end

  it "uses persisted value for validation if it hasn't been set" do
    user = User.create! :sex => :male
    User.find(user.id).read_attribute_for_validation(:sex).must_equal 'male'
  end

  it 'is valid with empty string assigned' do
    user = User.new
    user.role = ''
    user.must_be :valid?
  end

  it 'stores nil when empty string assigned' do
    user = User.new
    user.role = ''
    user.read_attribute(:role).must_be_nil
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

  it 'stores multiple value passed passed to new' do
    user = User.new(interests: [:music, :dancing])
    user.save!
    user.interests.must_equal %w(music dancing)
    User.find(user.id).interests.must_equal %w(music dancing)
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

  it 'stores custom values for multiple attributes' do
    User.delete_all

    klass = Class.new(User)
    klass.enumerize :interests, in: { music: 0, sports: 1, dancing: 2, programming: 3}, multiple: true

    user = klass.new
    user.interests << :music
    user.read_attribute(:interests).must_equal [0]
    user.interests.must_equal %w(music)
    user.save

    user = klass.find(user.id)
    user.interests.must_equal %w(music)
  end

  it 'adds scope' do
    User.delete_all

    user_1 = User.create!(status: :active, role: :admin)
    user_2 = User.create!(status: :blocked)

    User.with_status(:active).must_equal [user_1]
    User.with_status(:blocked).must_equal [user_2]
    User.with_status(:active, :blocked).to_set.must_equal [user_1, user_2].to_set

    User.without_status(:active).must_equal [user_2]
    User.without_status(:active, :blocked).must_equal []

    User.having_role(:admin).must_equal [user_1]
  end

  it 'ignores not enumerized values that passed to the scope method' do
    User.delete_all

    User.with_status(:foo).must_equal []
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

  it 'supports defining enumerized attributes on abstract class' do
    Document.delete_all

    document = Document.new
    document.visibility = :protected
    document.visibility.must_equal 'protected'
  end

  it 'supports defining enumerized scopes on abstract class' do
    Document.delete_all

    document_1 = Document.create!(visibility: :public)
    document_2 = Document.create!(visibility: :private)

    Document.with_visibility(:public).must_equal [document_1]
  end

  it 'validates uniqueness' do
    user = User.new
    user.status = :active
    user.save!

    user = UniqStatusUser.new
    user.status = :active
    user.valid?

    user.errors[:status].wont_be :empty?
  end

  it 'validates presence with multiple attributes' do
    user = InterestsRequiredUser.new
    user.interests = []
    user.valid?

    user.errors[:interests].wont_be :empty?

    user.interests = ['']
    user.valid?

    user.errors[:interests].wont_be :empty?

    user.interests = [:dancing, :programming]
    user.valid?

    user.errors[:interests].must_be_empty
  end

  it 'is valid after #becomes' do
    User.delete_all
    user = User.new
    user.sex = :male
    user.save!

    uniq_user = User.find(user.id).becomes(UniqStatusUser)
    uniq_user.valid?

    uniq_user.errors.must_be_empty
  end

  it 'supports multiple attributes in #becomes' do
    User.delete_all

    uniq_user = UniqStatusUser.new
    uniq_user.interests = [:sports, :dancing]
    uniq_user.sex = :male
    uniq_user.save!

    user = uniq_user.becomes(User)

    user.sex.must_equal uniq_user.sex
    user.interests.must_equal uniq_user.interests
  end

  it "doesn't update record" do
    Document.delete_all

    expected = Time.utc(2010, 10, 10)

    document = Document.new
    document.updated_at = expected
    document.save!

    document = Document.last
    document.save!

    assert_equal expected, document.updated_at
  end

  it 'changes from dirty should be serialized as scalar values' do
    user = User.create(:status => :active)
    user.status = :blocked

    assert_equal [1, 2], YAML.load(user.changes.to_yaml)[:status]
  end

  it 'does not change by the practical same value' do
    user = User.create!(status: 'active')
    user.reload
    user.status = 'active'

    user.changes.must_be_empty
  end

  it 'allows using update_all' do
    User.delete_all

    user = User.create(status: :active, account_type: :premium)

    User.update_all(status: :blocked)
    user.reload
    user.status.must_equal 'blocked'

    User.update_all(status: :active, account_type: :basic)
    user.reload
    user.status.must_equal 'active'
    user.account_type.must_equal 'basic'
  end

  it 'allows using update_all for multiple enumerize' do
    User.delete_all

    klass = Class.new(User)
    klass.enumerize :interests, in: { music: 0, sports: 1, dancing: 2, programming: 3}, multiple: true

    user = klass.create(status: :active)
    klass.update_all(status: :blocked, interests: [:music, :dancing])

    user = klass.find(user.id)
    user.status.must_equal 'blocked'
    user.interests.must_equal %w(music dancing)
  end

  it 'allows using update_all with values' do
    User.delete_all

    user = User.create(status: :active)

    User.update_all(status: 2)
    user.reload
    user.status.must_equal 'blocked'
  end

  it 'allows using update_all on relation objects' do
    User.delete_all

    user = User.create(status: :active, account_type: :premium)

    User.all.update_all(status: :blocked)
    user.reload
    user.status.must_equal 'blocked'
  end

  it 'allows using update_all on association relation objects' do
    User.delete_all
    Document.delete_all

    user = User.create
    document = Document.create(user: user, status: :draft)

    user.documents.update_all(status: :release)
    document.reload
    document.status.must_equal 'release'
  end

  it 'preserves string usage of update_all' do
    User.delete_all

    user = User.create(name: "Fred")

    User.update_all("name = 'Frederick'")
    user.reload
    user.name.must_equal 'Frederick'
  end

  it 'preserves interpolated array usage of update_all' do
    User.delete_all

    user = User.create(name: "Fred")

    User.update_all(["name = :name", {name: 'Frederick'}])
    user.reload
    user.name.must_equal 'Frederick'
  end

  it 'sets attribute to nil if given one is not valid' do
    User.delete_all

    user = User.create(status: :active)

    User.update_all(status: :foo)
    user.reload
    user.status.must_be_nil
  end

  it 'supports AR types serialization' do
    type = User.type_for_attribute('status')
    type.must_be_instance_of Enumerize::ActiveRecordSupport::Type
    serialized = type.serialize('blocked')
    serialized.must_equal 2
  end

  it 'has AR type itself JSON serializable' do
    type = User.type_for_attribute('status')
    type.as_json['attr'].must_equal 'status'
  end

  it "doesn't break YAML serialization" do
    user = YAML.load(User.create(status: :blocked).to_yaml)
    user.status.must_equal 'blocked'
  end

  # https://github.com/brainspec/enumerize/issues/304
  it "fallbacks to a raw passed value if AR type can't find value in the attribute" do
    table = User.arel_table
    sql = User.where(table[:account_type].matches '%foo%').to_sql

    sql.must_include 'LIKE \'%foo%\''
  end
end
