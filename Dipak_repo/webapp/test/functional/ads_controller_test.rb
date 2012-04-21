require File.dirname(__FILE__) + '/../test_helper'
require 'ads_controller'

# Re-raise errors caught by the controller.
class AdsController; def rescue_action(e) raise e end; end

class AdsControllerTest < Test::Unit::TestCase
  def setup
    @controller = AdsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_should_create_ad_click
    initial_count = AdClick.count
    get :show, { :id=> ads(:one) }
    assert_equal initial_count + 1, AdClick.count
  end

  def DISABLE_CANT_TEST_OUTSIDE_CONTROLLER_test_helper_should_mark_ad_viewed
    initial_count = AdView.count
    @controller.render_ad :width=>240, :height=>150, :name=>"ad_one"
    assert_equal initial_count + 1, AdView.count
  end
end
