require 'minitest/autorun'
require 'minitest/spec'
require 'mocha'
require 'active_support/core_ext/kernel/reporting'

$VERBOSE=true

require 'enumerize'

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
