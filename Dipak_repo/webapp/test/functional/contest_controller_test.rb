require File.dirname(__FILE__) + '/../test_helper'
require 'contest_controller'

# Re-raise errors caught by the controller.
class ContestController; def rescue_action(e) raise e end; end

class ContestControllerTest < Test::Unit::TestCase
  def setup
    @controller = ContestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_index_should_succeed
    login(users("quentin"))
    get :index
    assert_response :success
  end

  def test_invite_should_succeed
    login(users("quentin"))
    post :invite, :from_name=>"me", :from_email=>"me@example.com", :invitee => { "first_name" => ["A", "B", "C"], :email=> ["a@example.com", "b@example.com", "c@example.com"]}
    assert_redirected_to :action=>"thank_you"
    assert_equal 3, @emails.size
    assert_equal "a@example.com", @emails[0].to_addrs.first.address
    assert_equal "b@example.com", @emails[1].to_addrs.first.address
    assert_equal "c@example.com", @emails[2].to_addrs.first.address
  end

end
