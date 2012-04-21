require File.dirname(__FILE__) + '/../test_helper'
require 'profile_messages_controller'

# Re-raise errors caught by the controller.
class ProfileMessagesController; def rescue_action(e) raise e end; end

class ProfileMessagesControllerTest < Test::Unit::TestCase

  def setup
    @controller = ProfileMessagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_should_get_index
    login(users("quentin"))
    xhr :get, :index, :profile_id=>profiles(:buyer2)
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
  end

  def test_should_get_show
    login(users("quentin"))
    recipients = ProfileMessageRecipient.find_for_message(profile_messages(:message2), profiles(:buyer3))
    recipients.each { |r| assert_nil r.viewed_at }
    xhr :get, :show, :id=>profile_messages(:message2), :profile_id=>profiles(:buyer3)
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    recipients = ProfileMessageRecipient.find_for_message(profile_messages(:message2), profiles(:buyer3))
    recipients.each { |r| assert_not_nil r.viewed_at }
  end

  def test_should_get_new
    login(users("quentin"))
    get :new, :profile_id=>profiles(:buyer1)
    assert_response :success
  end

  def test_should_get_new_with_500_missing_profile_id
    login(users("quentin"))
    get :new
    assert_response 500
  end

  def test_should_create_profile_message_with_500_missing_profile_id
    login(users("quentin"))
    old_count = ProfileMessage.count
    xhr :post, :create, :profile_message_form => { :body=>"Example message" }
    assert_response 500, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_equal old_count, ProfileMessage.count
  end

  def test_should_create_profile_message_missing_fields
    login(users("quentin"))
    old_count = ProfileMessage.count
    xhr :post, :create, :profile_id=>profiles(:buyer1),:profile_message_form => { :from_profile_id=>profiles(:buyer1).id, :body=>"Example message" }
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_template "new"
    @profile_message_form = assigns(:profile_message_form)
    assert_not_nil @profile_message_form
    assert_equal 2, @profile_message_form.errors.count
    assert_equal old_count, ProfileMessage.count
  end

  def test_should_create_profile_message
    login(users("quentin"))
    old_count = ProfileMessage.count
    xhr :post, :create, :profile_id=>profiles(:buyer1),:profile_message_form => { :from_profile_id=>profiles(:buyer1).id, :send_to=>"all",:subject=>"My Subject", :body=>"Example message" }
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_template "_create_success"
    @profile_message_form = assigns(:profile_message_form)
    assert_not_nil @profile_message_form
    assert_equal 0, @profile_message_form.errors.count
    @profile_message = assigns(:profile_message)
    assert_not_nil @profile_message
    assert_equal 2, @profile_message.profile_message_recipients.length
    assert_equal old_count+1, ProfileMessage.count
    # should send notification of direct message
    assert_equal 2, @emails.size
  end

  def test_should_create_profile_message_no_direct_message_notification_if_disabled
    login(users("quentin"))

    # disable the direct message notification of the first profile found
    profile_list,profile_count,page_count = MatchingEngine.get_matches(:profile=>profiles(:buyer1), :mode=>:all, :result_filter=>:all)
    first_profile = profile_list.first
    first_profile.user.direct_message_frequency = 'D' # anything non-immediatae
    first_profile.user.save!

    old_count = ProfileMessage.count
    xhr :post, :create, :profile_id=>profiles(:buyer1),:profile_message_form => { :from_profile_id=>profiles(:buyer1).id, :send_to=>"all",:subject=>"My Subject", :body=>"Example message" }
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_template "_create_success"
    @profile_message_form = assigns(:profile_message_form)
    assert_not_nil @profile_message_form
    assert_equal 0, @profile_message_form.errors.count
    @profile_message = assigns(:profile_message)
    assert_not_nil @profile_message
    assert_equal 2, @profile_message.profile_message_recipients.length
    assert_equal old_count+1, ProfileMessage.count
    # should send notification of direct message to no one (same user for both profiles)
    assert_equal @profile_message.profile_message_recipients[0].to_profile.user_id, @profile_message.profile_message_recipients[1].to_profile.user_id
    assert_equal 0, @emails.size
  end

  def test_should_create_profile_message_with_filter
    login(users("quentin"))
    old_count = ProfileMessage.count
    xhr :post, :create, :profile_id=>profiles(:buyer1),:profile_message_form => { :from_profile_id=>profiles(:buyer1).id, :send_to=>"all", :filters=>"all", :subject=>"My Subject", :body=>"Example message" }
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_template "_create_success"
    @profile_message_form = assigns(:profile_message_form)
    assert_not_nil @profile_message_form
    assert_equal 0, @profile_message_form.errors.count
    @profile_message = assigns(:profile_message)
    assert_not_nil @profile_message
    assert_equal 2, @profile_message.profile_message_recipients.length
    assert_equal old_count+1, ProfileMessage.count
  end

  def test_mark_as_spam_succeeds
    spam_claim_count = SpamClaim.count
    login(users("quentin"))
    @profile = profiles(:buyer1)
    @profile_message = profile_messages(:message1)
    xhr :post, :mark_as_spam, :profile_id=>@profile.id, :id=>@profile_message.id
    assert_response :success, "#{@response.body}"
    assert_equal spam_claim_count+1, SpamClaim.count
    @profile_message.reload
    assert @profile_message.marked_as_spam
    claim = SpamClaim.find(:all).last
    assert_equal users(:quentin).id, claim.created_by_user_id
    assert_equal @profile_message.id, claim.claim_id
    assert_equal 'ProfileMessage', claim.claim_type
    assert_equal 1, @emails.size
  end

  def test_mark_as_spam_requires_login
    spam_claim_count = SpamClaim.count
    @profile = Profile.find('buyer1')
    xhr :post, :mark_as_spam, :id=>@profile.id
    assert_redirected_to :controller=>"sessions"
  end

  def test_mark_as_spam_requires_profile_id
    spam_claim_count = SpamClaim.count
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    xhr :post, :mark_as_spam
    assert_response :error
  end
end
