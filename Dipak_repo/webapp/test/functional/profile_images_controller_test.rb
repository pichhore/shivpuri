require File.dirname(__FILE__) + '/../test_helper'
require 'profile_images_controller'

# Re-raise errors caught by the controller.
class ProfileImagesController; def rescue_action(e) raise e end; end

class ProfileImagesControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileImagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index_should_require_login
    get :index, :profile_id=>profiles("buyer1")
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_should_show_index
    login(users("quentin"))
    get :index, :profile_id=>profiles("buyer1").id
    assert_response :success
    assert_template "index"
    assert_not_nil assigns(:profile_images)
    assert_equal 0, assigns(:profile_images).length
  end

  def test_create_should_require_login
    post :create, :profile_id=>profiles("buyer1").id
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_should_upload_and_thumbnail_on_create
    login(users("quentin"))
    post :create, :profile_id=>profiles("buyer1").id, :profile_image=>{ :uploaded_data=> fixture_file_upload('files/house1.jpg', 'image/jpeg')}
    assert_redirected_to :action=>"index"
    assert_nil flash[:error]
    assert_not_nil flash[:notice]
    # This number will be 4 if you have RMagick installed; may want to add a check to see if it is?
    assert_equal 1, Profile.find_by_id("buyer1").profile_images.length
  end

  def test_should_fail_if_not_an_image_type
    login(users("quentin"))
    post :create, :profile_id=>profiles("buyer1").id, :profile_image=>{ :uploaded_data=> fixture_file_upload('files/house1.jpg', 'document/tiff')}
    assert_redirected_to :action=>"index"
    assert_nil flash[:notice]
    assert_not_nil flash[:error]
  end

  def test_should_destroy_image
    login(users("quentin"))
    post :create, :profile_id=>profiles("buyer1").id, :profile_image=>{ :uploaded_data=> fixture_file_upload('files/house1.jpg', 'image/jpeg')}
    # This number will be 4 if you have RMagick installed; may want to add a check to see if it is?
    assert_equal 1, Profile.find_by_id("buyer1").profile_images.length
    post :destroy, :profile_id=>profiles("buyer1"), :id=>Profile.find_by_id("buyer1").profile_images.first.id
    assert_equal 0, Profile.find_by_id("buyer1").profile_images.length
  end

end
