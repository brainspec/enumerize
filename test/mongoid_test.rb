require 'test_helper'

silence_warnings do
  require 'mongoid'
end

Mongoid.configure do |config|
  config.sessions = { :default => { :database => 'enumerize-test-suite', hosts: ['127.0.0.1:27017'] } }
  config.use_utc = true
  config.include_root_in_json = true
end

describe Enumerize do
  class MongoidUser
    include Mongoid::Document
    extend Enumerize

    field :sex
    field :role
    enumerize :sex, :in => %w[male female]
    enumerize :role, :in => %w[admin user], :default => 'user'
    enumerize :mult, :in => %w[one two three four], :multiple => true
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

  it 'loads multiple properly' do
    model.delete_all

    model.create!(:mult => ['one', 'two'])
    user = model.first
    user.mult.to_a.must_equal ['one', 'two']
  end
end
