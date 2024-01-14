# frozen_string_literal: true

require 'test_helper'
require 'active_record'
require 'logger'
db = (ENV['DB'] || 'sqlite3').to_sym

silence_warnings do
  ActiveRecord::Migration.verbose = false
  if ActiveRecord::Base.respond_to?(:use_yaml_unsafe_load)
    ActiveRecord::Base.use_yaml_unsafe_load = true
  end
  ActiveRecord::Base.logger = Logger.new(nil)
  ActiveRecord::Base.configurations = {
    'sqlite3' => {
      'adapter' => 'sqlite3',
      'database' => ':memory:'
    },
    'mysql2' => {
      'adapter' => 'mysql2',
      'host' => '127.0.0.1',
      'username' => 'root',
      'password' => ENV['MYSQL_ROOT_PASSWORD'],
      'database' => 'enumerize_test',
      'encoding' => 'utf8mb4',
      'charset' => 'utf8mb4'
    },
    'postgresql' => {
      'adapter' => 'postgresql',
      'host' => 'localhost',
      'username' => ENV['POSTGRES_USER'],
      'password' => ENV['POSTGRES_PASSWORD']
    },
    'postgresql_master' => {
      'adapter' => 'postgresql',
      'host' => 'localhost',
      'username' => ENV['POSTGRES_USER'],
      'password' => ENV['POSTGRES_PASSWORD'],
      'database' => 'template1',
      'schema_search_path' => 'public'
    }
  }

  case db
  when :postgresql
    ActiveRecord::Base.establish_connection(:postgresql_master)
    ActiveRecord::Base.connection.recreate_database('enumerize_test')
  when :mysql2
    if ActiveRecord::Base.configurations.respond_to?(:[])
      ActiveRecord::Tasks::DatabaseTasks.create ActiveRecord::Base.configurations[db.to_s]
    else
      ActiveRecord::Tasks::DatabaseTasks.create ActiveRecord::Base.configurations.find_db_config(db.to_s)
    end

    ActiveRecord::Base.establish_connection(db)
  else
    ActiveRecord::Base.establish_connection(db)
  end
end

ActiveRecord::Base.connection.instance_eval do
  ActiveRecord::Migration.drop_table :users, if_exists: true
  ActiveRecord::Migration.drop_table :documents, if_exists: true

  create_table :users do |t|
    t.string :sex
    t.string :role
    t.string :lambda_role
    t.string :name
    t.string :interests
    t.integer :status
    t.text :settings
    t.integer :skill
    t.string :account_type, :default => :basic
    t.string :foo
    t.boolean :newsletter_subscribed, default: true
    t.json :store_accessor_store_with_no_defaults
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

  store :settings, accessors: [:language]

  enumerize :sex, :in => [:male, :female], scope: :shallow
  enumerize :language, :in => [:en, :jp]

  serialize :interests, Array
  enumerize :interests, :in => [:music, :sports, :dancing, :programming], :multiple => true

  enumerize :status, :in => { active: 1, blocked: 2 }, scope: true

  enumerize :skill, :in => { noob: 0, casual: 1, pro: 2 }, scope: :shallow

  enumerize :account_type, :in => [:basic, :premium]
  enumerize :newsletter_subscribed, in: { subscribed: true, unsubscribed: false }

  store_accessor :store_accessor_store_with_no_defaults, [:origin]
  enumerize :origin, in: [:browser, :app]

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

class SkipValidationsUser < ActiveRecord::Base
  self.table_name = "users"
  include SkipValidationsEnum
end

class DoNotSkipValidationsUser < ActiveRecord::Base
  self.table_name = "users"
  include DoNotSkipValidationsEnum
end

class SkipValidationsLambdaUser < ActiveRecord::Base
  self.table_name = "users"
  include SkipValidationsLambdaEnum
end

class SkipValidationsLambdaWithParamUser < ActiveRecord::Base
  self.table_name = "users"
  include SkipValidationsLambdaWithParamEnum
end

class ActiveRecordTest < Minitest::Spec
  it 'sets nil if invalid value is passed' do
    user = User.new
    user.sex = :invalid
    expect(user.sex).must_be_nil
  end

  it 'saves value' do
    User.delete_all
    user = User.new
    user.sex = :female
    user.save!
    expect(user.sex).must_equal 'female'
  end

  it 'loads value' do
    User.delete_all
    User.create!(:sex => :male)
    store_translations(:en, :enumerize => {:sex => {:male => 'Male'}}) do
      user = User.first
      expect(user.sex).must_equal 'male'
      expect(user.sex_text).must_equal 'Male'
    end
  end

  it 'sets nil if invalid stored attribute value is passed' do
    user = User.new
    user.language = :invalid
    expect(user.language).must_be_nil
  end

  it 'saves stored attribute value' do
    User.delete_all
    user = User.new
    user.language = :en
    user.save!
    user.reload
    expect(user.language).must_equal 'en'
  end

  it 'returns nil if store column is nil, uses .store_accessor, and has no default values for store\'s attributes' do
    User.delete_all
    user = User.create!
    user.update_column(:store_accessor_store_with_no_defaults, nil)
    user.reload
    expect(user.store_accessor_store_with_no_defaults).must_be_nil
    expect(user.origin).must_be_nil
  end

  it 'has default value' do
    expect(User.new.role).must_equal 'user'
    expect(User.new.attributes['role']).must_equal 'user'
  end

  it 'does not set default value for not selected attributes' do
    User.delete_all
    User.create!(:sex => :male)

    user = User.select(:id).first
    expect(user.attributes['role']).must_be_nil
    expect(user.attributes['lambda_role']).must_be_nil
  end

  it 'has default value with lambda' do
    expect(User.new.lambda_role).must_equal 'admin'
    expect(User.new.attributes['lambda_role']).must_equal 'admin'
  end

  it 'uses after_initialize callback to set default value' do
    User.delete_all
    User.create!(sex: 'male', lambda_role: nil)

    user = User.where(:sex => 'male').first
    expect(user.lambda_role).must_equal 'admin'
  end

  it 'uses default value from db column' do
    expect(User.new.account_type).must_equal 'basic'
  end

  it 'has default value with default scope' do
    UserWithDefaultScope = Class.new(User) do
      default_scope -> { having_role(:user) }
    end

    expect(UserWithDefaultScope.new.role).must_equal 'user'
    expect(UserWithDefaultScope.new.attributes['role']).must_equal 'user'
  end

  it 'validates inclusion' do
    user = User.new
    user.role = 'wrong'
    expect(user).wont_be :valid?
    expect(user.errors[:role]).must_include 'is not included in the list'
  end

  it 'sets value to enumerized field from db when record is reloaded' do
    user = User.create!(interests: [:music])
    User.find(user.id).update(interests: %i[music dancing])
    expect(user.interests).must_equal %w[music]
    user.reload
    expect(user.interests).must_equal %w[music dancing]
  end

  it 'has enumerized values in active record attributes after reload' do
    User.delete_all
    user = User.new
    user.status = :blocked
    user.save!
    user.reload
    expect(user.attributes["status"]).must_equal 'blocked'
  end

  it 'validates inclusion when using write_attribute with string attribute' do
    user = User.new
    user.send(:write_attribute, 'role', 'wrong')
    expect(user.read_attribute_for_validation(:role)).must_equal 'wrong'
    expect(user).wont_be :valid?
    expect(user.errors[:role]).must_include 'is not included in the list'
  end

  it 'validates inclusion when using write_attribute with symbol attribute' do
    user = User.new
    user.send(:write_attribute, :role, 'wrong')
    expect(user.read_attribute_for_validation(:role)).must_equal 'wrong'
    expect(user).wont_be :valid?
    expect(user.errors[:role]).must_include 'is not included in the list'
  end

  it 'validates inclusion on mass assignment' do
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(role: 'wrong')
    end
  end

  it "uses persisted value for validation if it hasn't been set" do
    user = User.create! :sex => :male
    expect(User.find(user.id).read_attribute_for_validation(:sex)).must_equal 'male'
  end

  it 'is valid with empty string assigned' do
    user = User.new
    user.role = ''
    expect(user).must_be :valid?
  end

  it 'stores nil when empty string assigned' do
    user = User.new
    user.role = ''
    expect(user.read_attribute(:role)).must_be_nil
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
    expect(user.interests).must_be_empty
    user.interests << :music
    expect(user.interests).must_equal %w(music)
    user.save!

    user = User.find(user.id)
    expect(user.interests).must_be_instance_of Enumerize::Set
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

  it 'stores multiple value passed passed to new' do
    user = User.new(interests: [:music, :dancing])
    user.save!
    expect(user.interests).must_equal %w(music dancing)
    expect(User.find(user.id).interests).must_equal %w(music dancing)
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
    User.delete_all

    klass = Class.new(User) do
      def self.name
        'UserSubclass'
      end
    end
    klass.enumerize :interests, in: { music: 0, sports: 1, dancing: 2, programming: 3}, multiple: true

    user = klass.new
    user.interests << :music
    expect(user.read_attribute(:interests)).must_equal [0]
    expect(user.interests).must_equal %w(music)
    user.save

    user = klass.find(user.id)
    expect(user.interests).must_equal %w(music)
  end

  it 'adds scope' do
    User.delete_all

    user_1 = User.create!(sex: :female, skill: :noob, status: :active, role: :admin)
    user_2 = User.create!(sex: :female, skill: :casual, status: :blocked)
    user_3 = User.create!(sex: :male, skill: :pro)

    expect(User.with_status(:active)).must_equal [user_1]
    expect(User.with_status(:blocked)).must_equal [user_2]
    expect(User.with_status(:active, :blocked).to_set).must_equal [user_1, user_2].to_set

    expect(User.without_status(:active)).must_equal [user_2]
    expect(User.without_status(:active, :blocked)).must_equal []

    expect(User.male).must_equal [user_3]
    expect(User.pro).must_equal [user_3]

    expect(User.not_male.to_set).must_equal [user_1, user_2].to_set
    expect(User.not_pro.to_set).must_equal [user_1, user_2].to_set
  end

  it 'ignores not enumerized values that passed to the scope method' do
    User.delete_all

    expect(User.with_status(:foo)).must_equal []
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
    Document.delete_all

    document = Document.new
    document.visibility = :protected
    expect(document.visibility).must_equal 'protected'
  end

  it 'supports defining enumerized scopes on abstract class' do
    Document.delete_all

    document_1 = Document.create!(visibility: :public)
    document_2 = Document.create!(visibility: :private)

    expect(Document.with_visibility(:public)).must_equal [document_1]
  end

  it 'validates uniqueness' do
    user = User.new
    user.status = :active
    user.save!

    user = UniqStatusUser.new
    user.status = :active
    user.valid?

    expect(user.errors[:status]).wont_be :empty?
  end

  it 'validates presence with multiple attributes' do
    user = InterestsRequiredUser.new
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

  it 'is valid after #becomes' do
    User.delete_all
    user = User.new
    user.sex = :male
    user.save!

    uniq_user = User.find(user.id).becomes(UniqStatusUser)
    uniq_user.valid?

    expect(uniq_user.errors).must_be_empty
  end

  it 'supports multiple attributes in #becomes' do
    User.delete_all

    uniq_user = UniqStatusUser.new
    uniq_user.interests = [:sports, :dancing]
    uniq_user.sex = :male
    uniq_user.save!

    user = uniq_user.becomes(User)

    expect(user.sex).must_equal uniq_user.sex
    expect(user.interests).must_equal uniq_user.interests
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

    assert_equal [1, 2], unsafe_yaml_load(user.changes.to_yaml)[:status]
  end

  it 'does not change by the practical same value' do
    user = User.create!(status: 'active')
    user.reload
    user.status = 'active'

    expect(user.changes).must_be_empty
  end

  it 'allows using update_all' do
    User.delete_all

    user = User.create(status: :active, account_type: :premium)

    User.update_all(status: :blocked)
    user.reload
    expect(user.status).must_equal 'blocked'

    User.update_all(status: :active, account_type: :basic)
    user.reload
    expect(user.status).must_equal 'active'
    expect(user.account_type).must_equal 'basic'
  end

  it 'allows using update_all for multiple enumerize' do
    User.delete_all

    klass = Class.new(User) do
      def self.name
        'UserSubclass'
      end
    end
    klass.enumerize :interests, in: { music: 0, sports: 1, dancing: 2, programming: 3}, multiple: true

    user = klass.create(status: :active)
    klass.update_all(status: :blocked, interests: [:music, :dancing])

    user = klass.find(user.id)
    expect(user.status).must_equal 'blocked'
    expect(user.interests).must_equal %w(music dancing)
  end

  it 'allows using update_all with values' do
    User.delete_all

    user = User.create(status: :active)

    User.update_all(status: 2)
    user.reload
    expect(user.status).must_equal 'blocked'
  end

  it 'allows using update_all on relation objects' do
    User.delete_all

    user = User.create(status: :active, account_type: :premium)

    User.all.update_all(status: :blocked)
    user.reload
    expect(user.status).must_equal 'blocked'
  end

  it 'allows using update_all on association relation objects' do
    User.delete_all
    Document.delete_all

    user = User.create
    document = Document.create(user: user, status: :draft)

    user.documents.update_all(status: :release)
    document.reload
    expect(document.status).must_equal 'release'
  end

  it 'preserves string usage of update_all' do
    User.delete_all

    user = User.create(name: "Fred")

    User.update_all("name = 'Frederick'")
    user.reload
    expect(user.name).must_equal 'Frederick'
  end

  it 'preserves interpolated array usage of update_all' do
    User.delete_all

    user = User.create(name: "Fred")

    User.update_all(["name = :name", {name: 'Frederick'}])
    user.reload
    expect(user.name).must_equal 'Frederick'
  end

  it 'sets attribute to nil if given one is not valid' do
    User.delete_all

    user = User.create(status: :active)

    User.update_all(status: :foo)
    user.reload
    expect(user.status).must_be_nil
  end

  it 'supports AR types serialization' do
    type = User.type_for_attribute('status')
    expect(type).must_be_instance_of Enumerize::ActiveRecordSupport::Type
    serialized = type.serialize('blocked')
    expect(serialized).must_equal 2
  end

  it 'has AR type itself JSON serializable' do
    type = User.type_for_attribute('status')
    expect(type.as_json['attr']).must_equal 'status'
  end

  it "doesn't break YAML serialization" do
    user = unsafe_yaml_load(User.create(status: :blocked).to_yaml)
    expect(user.status).must_equal 'blocked'
  end

  # https://github.com/brainspec/enumerize/issues/304
  it "fallbacks to a raw passed value if AR type can't find value in the attribute" do
    table = User.arel_table
    sql = User.where(table[:account_type].matches '%foo%').to_sql

    expect(sql).must_include 'LIKE \'%foo%\''
  end

  it 'supports boolean column as enumerized field' do
    User.delete_all

    User.create!(newsletter_subscribed: true)
    expect(User.find_by(newsletter_subscribed: true).newsletter_subscribed).must_equal 'subscribed'

    User.create!(newsletter_subscribed: false)
    expect(User.find_by(newsletter_subscribed: false).newsletter_subscribed).must_equal 'unsubscribed'
  end

  it 'has same value with original object when created by #dup' do
    user1 = User.new(skill: :casual)
    user2 = user1.dup
    expect(user2.skill).must_equal 'casual'
  end

  it 'has same value with original object when created by #clone' do
    user1 = User.new(skill: :casual)
    user2 = user1.clone
    expect(user2.skill).must_equal 'casual'
  end

  if Rails::VERSION::MAJOR >= 6
    it 'supports AR#insert_all' do
      User.delete_all

      User.insert_all([{ sex: :male }])
      User.insert_all([{ status: :active }])
      User.insert_all([{ interests: [:music, :sports] }])

      expect(User.exists?(sex: :male)).must_equal true
      expect(User.exists?(status: :active)).must_equal true
      expect(User.exists?(interests: [:music, :sports])).must_equal true
    end

    it 'supports AR#upsert_all' do
      User.delete_all

      User.upsert_all([{ sex: :male }])
      User.upsert_all([{ status: :active }])
      User.upsert_all([{ interests: [:music, :sports] }])

      expect(User.exists?(sex: :male)).must_equal true
      expect(User.exists?(status: :active)).must_equal true
      expect(User.exists?(interests: [:music, :sports])).must_equal true
    end
  end
end
