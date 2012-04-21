require File.dirname(__FILE__) + '/../test_helper'
require 'how_it_works_controller'

# Re-raise errors caught by the controller.
class HowItWorksController; def rescue_action(e) raise e end; end

class HowItWorksControllerTest < Test::Unit::TestCase
  def setup
    @controller = HowItWorksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
