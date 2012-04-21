require File.dirname(__FILE__) + '/../test_helper'
require 'profile_favorites_controller'

# Re-raise errors caught by the controller.
class ProfileFavoritesController; def rescue_action(e) raise e end; end

class ProfileFavoritesControllerTest < Test::Unit::TestCase

  def setup
    @controller = ProfileFavoritesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_create_profile_should_require_login
    xhr :post, :create, :profile_favorite => { }
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_should_create_profile_favorite_missing_profile_id
    login_as :quentin
    xhr :post, :create, :profile_favorite => { }
    old_count = ProfileFavorite.count
    assert_response 500, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_equal old_count, ProfileFavorite.count
  end

  def test_should_create_profile_favorite_missing_target_profile_id
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :post, :create, :profile_id=>profiles(:buyer2).id, :profile_favorite => { }
    @profile_favorite = assigns(:profile_favorite)
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Errors: #{@profile_favorite.errors.full_messages}"
    assert_not_nil @profile_favorite
    assert_equal old_count, ProfileFavorite.count
    assert_template "_create_error"
  end

  def test_should_create_profile_favorite
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :post, :create, :profile_id=>profiles(:buyer2).id, :profile_favorite => { :target_profile_id=>"owner1"}
    @profile_favorite = assigns(:profile_favorite)
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Errors: #{@profile_favorite.errors.full_messages}"
    assert_not_nil @profile_favorite
    assert_equal old_count+1, ProfileFavorite.count
    assert_template "_create_success", "Wrong template. Errors: #{@profile_favorite.errors.full_messages}"
  end

  def test_should_create_profile_favorite_with_target_profile_id_param
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :post, :create, :profile_id=>profiles(:buyer2).id, :target_profile_id=>"owner1"
    @profile_favorite = assigns(:profile_favorite)
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Errors: #{@profile_favorite.errors.full_messages}"
    assert_not_nil @profile_favorite
    assert_equal old_count+1, ProfileFavorite.count
    assert_template "_create_success", "Wrong template. Errors: #{@profile_favorite.errors.full_messages}"
  end

  def test_should_create_profile_favorite_only_once
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :post, :create, :profile_id=>profiles(:buyer1).id, :target_profile_id=>"owner1"
    assert_equal old_count, ProfileFavorite.count
    @profile_favorite = assigns(:profile_favorite)
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Errors: #{@profile_favorite.errors.full_messages}"
    assert_not_nil @profile_favorite
    assert_template "_create_success", "Wrong template. Errors: #{@profile_favorite.errors.full_messages}"
  end

  def test_should_destroy_profile_favorite_error_bad_id
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :delete, :destroy, :profile_id=>profiles(:buyer1).id, :id => "na"
    assert_equal old_count, ProfileFavorite.count
    assert_template nil
  end

  def test_should_destroy_profile_favorite_by_favorite_id
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :delete, :destroy, :profile_id=>profiles(:buyer1).id, :id => profile_favorites(:favorite1)
    assert_equal old_count-1, ProfileFavorite.count
    assert_template "_destroy_success"
  end

  def test_should_destroy_profile_favorite_by_profile_target_id
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :delete, :destroy, :profile_id=>profiles(:buyer1).id, :id => profile_favorites(:favorite1).target_profile_id
    assert_equal old_count-1, ProfileFavorite.count
    assert_template "_destroy_success"
  end

  def test_should_destroy_profile_favorite_error_not_allowed
    login_as :quentin
    old_count = ProfileFavorite.count
    xhr :delete, :destroy, :profile_id=>profiles(:buyer2).id, :id => profile_favorites(:favorite1)
    assert_equal old_count, ProfileFavorite.count
    assert_template nil
  end

end
