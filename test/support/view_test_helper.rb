require 'active_support/concern'
require 'active_support/testing/setup_and_teardown'

if defined?(ActionView::RoutingUrlFor)
  ActionView::RoutingUrlFor.send(:include, ActionDispatch::Routing::UrlFor)
end

module ViewTestHelper
  extend ActiveSupport::Concern

  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior

  included do
    setup :set_controller
  end

  def set_controller
    @controller = MockController.new
  end

  def method_missing(method, *args)
    super unless method.to_s =~ /_path$/
  end

  def respond_to?(method, include_private=false)
    method.to_s =~ /_path$/ || super
  end

  def protect_against_forgery?
    false
  end
end
