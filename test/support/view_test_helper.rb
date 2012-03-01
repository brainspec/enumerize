require 'active_support/concern'
require 'active_support/testing/setup_and_teardown'

module ViewTestHelper
  extend ActiveSupport::Concern

  include ActiveSupport::Testing::SetupAndTeardown
  include ActionView::TestCase::Behavior
  include SimpleForm::ActionViewExtensions::FormHelper

  included do
    setup :set_controller
  end

  def set_controller
    @controller = MockController.new
  end

  def user_path(*args)
    '/users'
  end
  alias :users_path :user_path

  def protect_against_forgery?
    false
  end
end
