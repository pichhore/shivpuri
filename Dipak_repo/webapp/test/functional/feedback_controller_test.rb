require File.dirname(__FILE__) + '/../test_helper'
require 'feedback_controller'

# Re-raise errors caught by the controller.
class FeedbackController; def rescue_action(e) raise e end; end

class FeedbackControllerTest < Test::Unit::TestCase
  def setup
    @controller = FeedbackController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_should_show_new
    get :new
    assert_response :success
    assert_not_nil assigns(:feedback)
    assert_nil assigns(:feedback).first_name
  end

  def test_should_show_new_prefilled
    login(users("quentin"))
    get :new
    assert_response :success
    assert_not_nil assigns(:feedback)
    assert_equal users("quentin").first_name, assigns(:feedback).first_name
    assert_equal users("quentin").last_name, assigns(:feedback).last_name
    assert_equal users("quentin").email, assigns(:feedback).email
  end

  def test_should_show_validate_fields
    post :create, { :feedback=> { }}
    assert_response :success
    assert_not_nil assigns(:feedback)
    assert_equal 4, assigns(:feedback).errors.count
    assert_template "new"
    assert_equal 0, @emails.length
  end

  def test_should_create_feedback
    post :create, { :feedback=> { :first_name=>"Joe", :last_name=>"Schmoe", :email=>"joe@schmoe.com", :comments=>"Test"}}
    assert_redirected_to({:action=>"thanks" }, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}.")
    assert_not_nil assigns(:feedback)
    assert_equal 0, assigns(:feedback).errors.count
    assert_equal 1, @emails.length
  end

end
