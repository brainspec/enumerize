require 'test_helper'

silence_warnings do
  require 'mongoid'
end

Mongoid.configure do |config|
  config.master  = Mongo::Connection.new('127.0.0.1', 27017).db('enumerize-test-suite')
  config.use_utc = true
  config.include_root_in_json = true
end

describe Enumerize do
  class MongoidUser
    include Mongoid::Document
    include Enumerize

    field :sex
    field :role
    enumerize :sex, :in => %w[male female]
    enumerize :role, :in => %w[admine user], :default => 'user'
  end

  before { $VERBOSE = nil }
  after  { $VERBOSE = true }

  let(:model) { MongoidUser }

  it 'sets nil if invalid value is passed' do
    user = model.new
    user.sex = :invalid
    user.sex.must_equal nil
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
