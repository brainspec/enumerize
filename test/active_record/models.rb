class User < ActiveRecord::Base
  include Enumerize

  enumerize :sex, :in => [:male, :female]

  enumerize :role, :in => [:user, :admin], :default => :user
end
