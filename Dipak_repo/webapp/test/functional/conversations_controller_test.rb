require File.dirname(__FILE__) + '/../test_helper'
require 'conversations_controller'

# Re-raise errors caught by the controller.
class ConversationsController; def rescue_action(e) raise e end; end

class ConversationsControllerTest < Test::Unit::TestCase
  def setup
    @controller = ConversationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_should_display_all_sent_received_messages
    login(users(:quentin))
    @owner2 = profiles(:owner2)
    @buyer2 = profiles(:buyer2)
    get :show, { :id=> @owner2.id, :profile_id=> @buyer2.id }
    assert_response :success
    assert_not_nil assigns(:profile_message_recipients)
    assert_equal 2, assigns(:profile_message_recipients).length # 1 sent, 1 received
  end

  def test_show_should_mark_messages_as_read
    login(users(:quentin))
    @owner2 = profiles(:owner2)
    @buyer2 = profiles(:buyer2)
    get :show, { :id=> @owner2.id, :profile_id=> @buyer2.id }
    assert_response :success
    assert_not_nil assigns(:profile_message_recipients)
    assert_equal 2, assigns(:profile_message_recipients).length # 1 sent, 1 received
    assigns(:profile_message_recipients).each do |pmr|
      assert pmr.unread? if pmr.to_profile_id == @owner2.id
      assert !pmr.unread? if pmr.to_profile_id == @buyer2.id
    end
  end

  def test_create_should_return_status_401_on_failure
    login(users(:quentin))
    @owner2 = profiles(:owner2)
    @buyer2 = profiles(:buyer2)
    message_count = ProfileMessage.count
    post :create, { :id=> @owner2.id, :profile_id=>@buyer2.id, :profile_message_form=>{ :from_profile_id=>@buyer2.id, :body=>"Test Message 1", :indiv_profile_id=>@owner2.id} }
    assert_response 401, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_not_nil assigns(:profile_message_form)
    assert_equal 1, assigns(:profile_message_form).errors.length
    assert_equal message_count, ProfileMessage.count
  end

  def test_create_should_create_new_message
    login(users(:quentin))
    @owner2 = profiles(:owner2)
    @buyer2 = profiles(:buyer2)
    message_count = ProfileMessage.count
    post :create, { :id=> @owner2.id, :profile_id=>@buyer2.id, :profile_message_form=>{ :from_profile_id=>@buyer2.id, :subject=>"Test 1", :body=>"Test Message 1", :indiv_profile_id=>@owner2.id} }
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_not_nil assigns(:profile_message_form)
    assert_equal 0, assigns(:profile_message_form).errors.length
    assert_equal message_count+1, ProfileMessage.count
  end

  def test_create_should_create_only_one_new_message
    login(users(:quentin))
    @owner2 = profiles(:owner2)
    @buyer2 = profiles(:buyer2)
    message_count = ProfileMessage.count

    post :create, { :id=> @owner2.id, :profile_id=>@buyer2.id, :profile_message_form=>{ :from_profile_id=>@owner2.id, :body=>"Create and share your work online.\n\nWelcome to Jaymon Inc documents and spreadsheets program, powered by Google. Get started creating new documents, or upload your existing documents. The familiar desktop-feel makes editing easy, and the sharingtools make it easy to choose who can edit or view your files.\n\n    * Keep your documents current.\n      It's easy to make sure everyone sees the most updated version of your file, everytime. When there are multiple people editing at once, we'll keep a record so you can see who added and deleted what, when.\n    * Edit your documents and spreadsheets from anywhere.\n      All you need is a Web browser - your documents and spreadsheets are stored securely online. To work on documents offline, or distribute them as attachments, simply save a copy to your own computer in the format that works best for you.\n    * Share changes in real-time.\n      Invite people to your documents/spreadsheets and make changes together, at the same time. Your sharing tools are integrated with your Gmail contact list so it's easy to invite new collaborators and viewers within an organization.", :indiv_profile_id=>@owner2.id, :subject=>"Re: looking at your profile"} }
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_not_nil assigns(:profile_message_form)
    assert_equal 0, assigns(:profile_message_form).errors.length
    assert_equal message_count+1, ProfileMessage.count
    @profile_message = assigns(:profile_message)
    assert_not_nil @profile_message
    assert_equal 1, @profile_message.profile_message_recipients.length
    assert_equal @buyer2.id, @profile_message.profile_message_recipients.first.from_profile_id
    assert_equal @owner2.id, @profile_message.profile_message_recipients.first.to_profile_id
  end

end
