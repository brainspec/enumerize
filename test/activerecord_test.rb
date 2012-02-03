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
  end
end

class User < ActiveRecord::Base
  include Enumerize

  enumerize :sex, :in => [:male, :female]

  enumerize :role, :in => [:user, :admin], :default => :user
end

describe Enumerize::Integrations::ActiveRecord do
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
    I18n.backend.store_translations(:en, :enumerize => {:sex => {:male => 'Male'}})
    User.create!(:sex => :male)
    user = User.first
    user.sex.must_equal 'male'
    user.sex_text.must_equal 'Male'
  end

  it 'has default value' do
    User.new.role.must_equal 'user'
  end
end
