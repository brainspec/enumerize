require 'test_helper'
require 'active_record'
require 'logger'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migrator.migrate File.expand_path("../active_record/migrate", __FILE__)
require File.expand_path('../active_record/models', __FILE__)

describe Enumerize::Integrations::ActiveRecord do
  it 'sets nil if invalid value is passed' do
    user = User.new
    user.sex = :invalid
    user.sex.must_equal nil
  end

  it 'saves value' do
    user = User.new
    user.sex = :female
    user.save!
    user.sex.must_equal 'female'
  end
end
