require 'test_helper'

begin

silence_warnings do
  require 'mongo_mapper'
end

MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database   = 'enumerize-test-suite-of-mongomapper'

describe Enumerize do
  class MongoMapperUser
    include MongoMapper::Document
    extend Enumerize

    key :sex
    key :role

    enumerize :sex, :in => %w[male female]
    enumerize :role, :in => %w[admin user], :default => 'user'
  end

  before { $VERBOSE = nil }
  after  { $VERBOSE = true }

  let(:model) { MongoMapperUser }

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
end

rescue LoadError
  # Skip
end
