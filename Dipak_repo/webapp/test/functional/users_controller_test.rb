require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_signup
    @users = User.find(:all)
    create_user
    assert_response :redirect
    assert_redirected_to thanks_new_user_url
    assert_equal @users.length+1, User.find(:all).length
  end

  def test_should_require_password_on_signup
    @users = User.find(:all)
    create_user(:password => nil)
    assert assigns(:user).errors.on(:password)
    assert_response :success
    assert_equal @users.length, User.find(:all).length
  end

  def test_should_require_password_confirmation_on_signup
    @users = User.find(:all)
    create_user(:password_confirmation => nil)
    assert assigns(:user).errors.on(:password_confirmation)
    assert_response :success
    assert_equal @users.length, User.find(:all).length
  end

  def test_should_require_email_on_signup
    @users = User.find(:all)
    create_user(:email => nil)
    assert assigns(:user).errors.on(:email)
    assert_response :success
    assert_equal @users.length, User.find(:all).length
  end

  def test_should_require_email_format_on_signup
    @users = User.find(:all)
    create_user(:email => 'joe')
    assert assigns(:user).errors.on(:email)
    assert_response :success
    assert_equal @users.length, User.find(:all).length
  end

  def test_should_activate_user
    assert_nil User.authenticate('inactive1', 'test')
    get :activate, :activation_code => users(:inactive1).activation_code
    assert_redirected_to :controller=>"account", :action=>"profiles"
    assert_not_nil flash[:notice]
    assert_equal users(:inactive1), User.authenticate('inactive1', 'test')
    assert session[:user]
    assert_equal users(:inactive1).id, session[:user]
  end
  
  def test_should_activate_owner_and_redirect_to_images_on_create_profile
    assert_nil User.authenticate('inactive1', 'test')
    get :activate, :activation_code => users(:inactive1).activation_code, :profile_id=>profiles(:owner8).id
    #assert_redirected_to :controller=>"account", :action=>"profiles"
    #assert_redirected_to :controller=>"profile_images", :new=>"true"
    assert_redirected_to profile_profile_images_path(profiles(:owner8), :new=>"true")
    assert_not_nil flash[:notice]
    assert_equal users(:inactive1), User.authenticate('inactive1', 'test')
    assert session[:user]
    assert_equal users(:inactive1).id, session[:user]
  end

  protected
    def create_user(options = {})
      post :create, :user => { :first_name=>'first', :last_name=>'last', :login => 'quire', :email => 'quire@example.com',
        :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
