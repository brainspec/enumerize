require 'minitest/autorun'
require 'minitest/spec'
require 'active_support/core_ext/kernel/reporting'

$VERBOSE=true

module SimpleForm
  module Rails
    def self.env
      ActiveSupport::StringInquirer.new("test")
    end
  end
end

require 'enumerize'

Dir["#{File.dirname(__FILE__)}/support/*.rb"].each do |file|
  require file
end

module MiscHelpers
  def store_translations(locale, translations, &block)
    begin
      I18n.backend.store_translations locale, translations
      yield
    ensure
      I18n.reload!
    end
  end
end

class MiniTest::Spec
  include MiscHelpers
end
