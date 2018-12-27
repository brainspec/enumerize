# frozen_string_literal: true

require 'active_record'
require 'sequel'

module EnumerizeExtention
  def self.included(base)
    case
    when base < ActiveRecord::Base
      base.extend Enumerize
    when base < Sequel::Model
      base.plugin :enumerize
    end
  end
end

module SkipValidationsEnum
  def self.included(base)
    base.include EnumerizeExtention
    base.enumerize :foo, :in => [:bar, :baz], :skip_validations => true
  end
end

module DoNotSkipValidationsEnum
  def self.included(base)
    base.include EnumerizeExtention
    base.enumerize :foo, :in => [:bar, :baz], :skip_validations => false
  end
end

module SkipValidationsLambdaEnum
  def self.included(base)
    base.include EnumerizeExtention
    base.enumerize :foo, :in => [:bar, :baz], :skip_validations => lambda { true }
  end
end

module SkipValidationsLambdaWithParamEnum
  def self.included(base)
    base.include EnumerizeExtention
    base.enumerize :foo, :in => [:bar, :baz], :skip_validations => lambda { |record| true }
  end
end
