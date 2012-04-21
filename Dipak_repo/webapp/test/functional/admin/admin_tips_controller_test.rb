require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/admin_tips_controller'

# Re-raise errors caught by the controller.
class Admin::AdminTipsController; def rescue_action(e) raise e end; end

class Admin::AdminTipsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::AdminTipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
