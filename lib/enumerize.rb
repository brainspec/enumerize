require 'active_support/concern'
require 'i18n'
require 'enumerize/version'

module Enumerize
  autoload :Attribute, 'enumerize/attribute'
  autoload :Value,     'enumerize/value'

  extend ActiveSupport::Concern

  module ClassMethods
    def enumerize(*args, &block)
      Attribute.new(self, *args).attach!
    end
  end
end
