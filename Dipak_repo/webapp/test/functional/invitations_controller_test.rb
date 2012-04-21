require File.dirname(__FILE__) + '/../test_helper'
require 'invitations_controller'

# Re-raise errors caught by the controller.
class InvitationsController; def rescue_action(e) raise e end; end

class InvitationsControllerTest < Test::Unit::TestCase

  def setup
    @controller = InvitationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
  end

  def DISABLED_test_should_get_index
    get :index
    assert_response :success
    assert assigns(:invitations)
  end

  def test_get_new_should_require_login
    get :new
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_should_get_new
    login(users(:quentin))
    get :new
    assert_response :success
  end

  def test_get_create_should_require_login
    post :create
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_should_create_invitation
    login(users(:quentin))
    assert_equal 0, @emails.length
    old_count = Invitation.count
    post :create, :invitation => { :user_id=>users(:quentin).id, :to_email=>"foo@bar.com", :to_first_name=>"Foo", :to_last_name=>"Bar", :invitation_message=>"Something" }
    assert_equal old_count+1, Invitation.count
    assert_equal 1, @emails.length
    # puts @emails.first.body

    assert_redirected_to thanks_new_invitation_path
  end

  def test_create_should_error_with_missing_fields
    login(users(:quentin))
    old_count = Invitation.count
    post :create, :invitation => { :user_id=>users(:quentin).id }
    assert_equal old_count, Invitation.count
    assert_equal 2, assigns(:invitation).errors.length
    assert_response :success
    assert_template "new"
  end

  def test_should_show_invitation_without_login
    @invitation = invitations(:one)
    assert_not_nil @invitation
    assert_nil @invitation.accepted_at
    get :show, :id => 1
    assert_redirected_to :controller=>"home", :action=>"index"
    @invitation.reload
    assert_not_nil @invitation.accepted_at
  end

  def DISABLED_test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def DISABLED_test_should_update_invitation
    put :update, :id => 1, :invitation => { }
    assert_redirected_to invitation_path(assigns(:invitation))
  end

  def DISABLED_test_should_destroy_invitation
    old_count = Invitation.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Invitation.count

    assert_redirected_to invitations_path
  end
end
