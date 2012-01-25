class User < ActiveRecord::Base
  include Enumerize::Integrations::ActiveRecord

  enumerize :sex, :in => [:male, :female]
end
