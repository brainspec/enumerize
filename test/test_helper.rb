# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/spec'
require 'active_support/core_ext/kernel/reporting'
require 'active_model'
require 'active_job'
require 'rails'
begin
  require 'mongoid'
rescue LoadError
end

module RailsAdmin
end

require 'simple_form'
SimpleForm.setup {}

require 'formtastic'

module EnumerizeTest
  class Application < Rails::Application
    config.active_support.deprecation = :stderr
    config.active_support.test_order = :random
    config.eager_load = false
    config.secret_key_base = 'secret'
  end
end

EnumerizeTest::Application.initialize!

$VERBOSE=true

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

  def unsafe_yaml_load(yaml)
    if YAML.respond_to?(:unsafe_load)
      YAML.unsafe_load(yaml)
    else
      YAML.load(yaml)
    end
  end
end

class Minitest::Spec
  include MiscHelpers
end
