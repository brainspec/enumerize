require 'active_support/concern'
require 'enumerize/version'

module Enumerize
  autoload :Attribute,    'enumerize/attribute'
  autoload :Value,        'enumerize/value'
  autoload :Integrations, 'enumerize/integrations'

  extend ActiveSupport::Concern

  include Integrations::Basic
end
