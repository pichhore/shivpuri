require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_profiles_not_logged_in
    get :profiles
    assert_redirected_to :controller => 'sessions', :action => 'new'
  end

  def test_profiles_no_profiles
    login(users("aaron"))
    get :profiles
    assert_response :success
    assert_template "profiles"
    assert_not_nil (assigns(:profiles))
  end

  def test_profiles_one_profile
    users("aaron").profiles << profiles("buyer1")
    login(users("aaron"))
    get :profiles
    assert_response :success
    assert_template "profiles"
    assert_not_nil (assigns(:profiles))
  end

  def test_profiles_more_than_one_profile
    users("aaron").profiles << profiles("buyer1")
    users("aaron").profiles << profiles("buyer2")
    login(users("aaron"))
    get :profiles
    assert_response :success
    assert_template "profiles"
    assert_not_nil (assigns(:profiles))
  end

  def test_forgot_password
    @user = users("aaron")
    # error
    post :forgot_password, :email => @user.email+"_foo"
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_tag :tag => "div",:attributes => { :class => "error" }
    # success
    post :forgot_password, :email => @user.email
    assert_redirected_to({ :controller=>'sessions', :action => 'new'}, "Response was #{@response.response_code}. Message: #{@response.body}")
    # Test that the email was sent and that its contents have a properly-formed URL
    assert_equal 1, @emails.size
    @email = @emails.first
    assert_equal @user.email, @email.to[0]
    assert_match /\/account\/change_password/, @email.body
  end

  def test_change_password
    @user = users("aaron")
    post :forgot_password, :email => @user.email
    @user.reload # get the generated token
    @emails.clear # reset, since the last action generated an email
    get :change_password, :id => @user.id, :key => @user.security_token
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    # error
    post :change_password, :id => @user.id,
         :user => { :password => "test123", :password_confirmation => "test123" }
    assert_response :error, "Response was #{@response.response_code}. Message: #{@response.body}"
    # error
    post :change_password, :id => @user.id, :key => @user.security_token,
         :user => { :password => "test12", :password_confirmation => "test123" }
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_tag :tag => "div",:attributes => { :class => "formError" }
    # success
    post :change_password, :id => @user.id, :key => @user.security_token,
         :user => { :password => "test123", :password_confirmation => "test123" }
    assert_redirected_to({ :controller=>'sessions', :action => 'new'}, "Response was #{@response.response_code}. Message: #{@response.body}")

    # Test that the email was sent and that its contents have a properly-formed URL
    assert_equal 1, @emails.size
    @email = @emails.first
    assert_equal @user.email, @email.to[0]
    assert_no_match /test123/, @email.body
  end

  def test_change_password_logged_in
    @user = users("aaron")
    post :change_password, {:id => @user.id, :user => { :password => "test123", :password_confirmation => "test123" }},{:user=>@user}
    assert_redirected_to :action => 'settings'

    # Test that the email was sent and that its contents have a properly-formed URL
    assert_equal 1, @emails.size
    @email = @emails.first
    assert_equal @user.email, @email.to[0]
    assert_no_match /test123/, @email.body
  end

  def test_settings_should_require_login
    get :settings
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_settings_should_show
    login(users("aaron"))
    get :settings
    assert_response :success
    assert_template "settings"
    assert_equal 0, @emails.length
  end

  def test_settings_should_update_no_password_change
    @user = users("aaron")
    login(@user)
    original_crypted_password = @user.crypted_password
    post :settings, :user=>{ :first_name => "foo", :last_name=> "bar", :email=>"foo@bar.com"}
    assert_redirected_to :action=>"settings"
    @user.reload
    assert_equal "foo", @user.first_name
    assert_equal "bar", @user.last_name
    assert_equal "foo@bar.com", @user.email
    assert_equal original_crypted_password, @user.crypted_password
    assert_equal 0, @emails.length # no password was changed
  end

  def test_settings_should_update_with_password_change
    @user = users("aaron")
    login(@user)
    original_crypted_password = @user.crypted_password
    post :settings, :user=>{ :first_name => "foo", :last_name=> "bar", :email=>"foo@bar.com"}, :change_password=>"foo", :change_password_confirmation=>"foo"
    assert_redirected_to :action=>"settings"
    @user.reload
    assert_equal "foo", @user.first_name
    assert_equal "bar", @user.last_name
    assert_equal "foo@bar.com", @user.email
    assert original_crypted_password != @user.crypted_password
    assert_equal 1, @emails.length # no password was changed
  end

  def test_settings_should_update_with_password_change
    @user = users("aaron")
    login(@user)
    original_crypted_password = @user.crypted_password
    post :settings, :user=>{ :first_name => "foo", :last_name=> "bar", :email=>"foo@bar.com"}, :change_password=>"foo", :change_password_confirmation=>"foo2"
    assert_response :success
    assert_template "settings"
    assert_not_nil flash[:error]
    assert_equal 0, @emails.length # no password was changed
  end

  def test_digest_frequency_should_require_login
    get :digest_frequency
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_digest_frequency_should_show
    login(users("aaron"))
    get :digest_frequency
    assert_response :success
    assert_template "digest_frequency"
    assert_equal 0, @emails.length
  end

  def test_digest_frequency_should_update
    @user = users("aaron")
    login(@user)
    original_setting = @user.digest_frequency # [D]aily
    post :digest_frequency, :user=>{ :digest_frequency=>"W"}
    assert_redirected_to :action=>"digest_frequency"
    assert_not_nil flash[:notice]
  end

end
