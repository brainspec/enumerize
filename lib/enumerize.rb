require 'active_support/concern'
require 'enumerize/version'

module Enumerize
  autoload :Attribute,    'enumerize/attribute'
  autoload :Value,        'enumerize/value'
  autoload :Base,         'enumerize/base'
  autoload :ActiveRecord, 'enumerize/activerecord'

  extend ActiveSupport::Concern

  include Enumerize::Base

  included do
    if defined?(::ActiveRecord::Base) && self < ::ActiveRecord::Base
      include Enumerize::ActiveRecord
    end
  end

  begin
    require 'simple_form'
    require 'enumerize/hooks/simple_form'
  rescue LoadError
  end
end
