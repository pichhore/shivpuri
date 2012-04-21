require File.dirname(__FILE__) + '/../test_helper'
require 'profile_matches_controller'

# Re-raise errors caught by the controller.
class ProfileMatchesController; def rescue_action(e) raise e end; end

class ProfileMatchesControllerTest < Test::Unit::TestCase

  def setup
    @controller = ProfileMatchesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index_xhr_defaults
    login(users("quentin"))
    xhr :get, :index, :id=>profiles(:buyer1).id
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_template "profile_matches/_buyer_matches"
    assert_not_nil assigns(:page_number)
    assert_equal 1, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 2, assigns(:profiles).length
  end

  def test_should_get_index_xhr_page_2
    login(users("quentin"))
    xhr :get, :index, :id=>profiles(:buyer1).id, :page_number=>2
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_template "profile_matches/_buyer_matches"
    assert_not_nil assigns(:page_number)
    assert_equal 2, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 0, assigns(:profiles).length
  end

  def test_should_get_index_xhr_filter_by_new
    login(users("quentin"))
    xhr :get, :index, :id=>profiles(:buyer1).id, :result_filter=>"new"
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    assert_template "profile_matches/_buyer_matches"
    assert_not_nil assigns(:page_number)
    assert_equal 1, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 2, assigns(:profiles).length
  end

  def NOT_SUPPORTED_test_should_get_new
    get :new
    assert_response :success
  end

  def NOT_SUPPORTED_test_should_create_profile_match
    old_count = ProfileMatch.count
    post :create, :profile_match => { }
    assert_equal old_count+1, ProfileMatch.count

    assert_redirected_to profile_profile_match_path(assigns(:profile_match))
  end

  def NOT_SUPPORTED_test_should_show_profile_match
    get :show, :id => 1
    assert_response :success
  end

  def NOT_SUPPORTED_test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def NOT_SUPPORTED_test_should_update_profile_match
    put :update, :id => 1, :profile_match => { }
    assert_redirected_to profile_profile_match_path(assigns(:profile_match))
  end

  def NOT_SUPPORTED_test_should_destroy_profile_match
    old_count = ProfileMatch.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ProfileMatch.count

    assert_redirected_to profile_profile_matches_path
  end
end
