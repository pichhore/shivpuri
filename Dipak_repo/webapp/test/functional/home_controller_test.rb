require File.dirname(__FILE__) + '/../test_helper'
require 'home_controller'

# Re-raise errors caught by the controller.
class HomeController; def rescue_action(e) raise e end; end

class HomeControllerTest < Test::Unit::TestCase

  # turn off tx fixtures for this test, as prev tests are messing things up
  # the next test class will turn it back on, allowing tests to run faster
  self.use_transactional_fixtures = false

  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template "index"
  end

  def test_learn
    get :learn
    assert_response :success
    assert_template "learn"
  end

  def test_feedback
    get :feedback
    assert_response :success
    assert_template "feedback"
  end

  def test_preview_missing_id
    get :preview
    assert_response :error
  end

  def test_preview_missing_zip_code
    post :preview, :id=>"buyer"
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78701", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 1, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:total_profiles)
    assert_equal 3, assigns(:total_profiles)
    assert_not_nil assigns(:profiles)
    assert_equal 3, assigns(:profiles).length
  end

  def test_preview_buyer_success
    post :preview, :id=>"buyer", :zip_code=>"78613"
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 1, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:total_profiles)
    assert_equal 3, assigns(:total_profiles)
    assert_not_nil assigns(:profiles)
    assert_equal 3, assigns(:profiles).length
  end

  def test_preview_buyer_success_page_2
    post :preview, :id=>"buyer", :zip_code=>"78613", :page_number=>2
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 2, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 0, assigns(:profiles).length
  end

  def test_preview_buyer_xhr_success
    xhr :post, :preview, :id=>"buyer", :zip_code=>"78613"
    assert_response :success
  end

  def test_preview_buyer_agent_success
    post :preview, :id=>"buyer_agent", :zip_code=>"78613"
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 1, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:total_profiles)
    assert_equal 3, assigns(:total_profiles)
    assert_not_nil assigns(:profiles)
    assert_equal 3, assigns(:profiles).length
  end

  def test_preview_buyer_agent_success_page_2
    post :preview, :id=>"buyer_agent", :zip_code=>"78613", :page_number=>2
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 2, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 0, assigns(:profiles).length
  end

  def test_preview_owner_success
    post :preview, :id=>"owner", :zip_code=>"78613"
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 1, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 2, assigns(:profiles).length
  end

  def test_preview_owner_success_page_2
    post :preview, :id=>"owner", :zip_code=>"78613", :page_number=>2
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 2, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 0, assigns(:profiles).length
  end

  def test_preview_seller_agent_success
    post :preview, :id=>"seller_agent", :zip_code=>"78613"
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 1, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 2, assigns(:profiles).length
  end

  def test_preview_seller_agent_success_page_2
    post :preview, :id=>"seller_agent", :zip_code=>"78613", :page_number=>2
    assert_response :success
    assert_template "preview_results"
    assert_not_nil assigns(:zip_code)
    assert_equal "78613", assigns(:zip_code)
    assert_not_nil assigns(:page_number)
    assert_equal 2, assigns(:page_number)
    assert_not_nil assigns(:total_pages)
    assert_equal 1, assigns(:total_pages)
    assert_not_nil assigns(:profiles)
    assert_equal 0, assigns(:profiles).length
  end

  def test_preview_buyer_missing_target_profile_id
    get :preview_buyer
    assert_response :error
  end

  def test_preview_owner_missing_target_profile_id
    get :preview_owner
    assert_response :error
  end

  def test_preview_buyer_should_show
    get :preview_buyer, :id=>'buyer1'
    assert_response :success
    assert_template "preview_buyer"
    assert_not_nil assigns(:target_profile)
    assert_nil assigns(:profile)
  end

  def test_preview_owner_should_show
    get :preview_owner, :id=>'owner1'
    assert_response :success
    assert_template "preview_owner"
    assert_not_nil assigns(:target_profile)
    assert_nil assigns(:profile)
  end

  def test_logged_in_user_should_go_directly_to_setup
    login(users("quentin"))
    get :index
    assert_response :success
    assert_template "index"
    assert_match /profiles\/new/,@response.body
  end

  def test_guest_user_should_go_to_preview_page
    get :index
    assert_response :success
    assert_template "index"
    assert_match /home\/preview/,@response.body
  end

  def test_property_should_show_owner_page_if_found
    get :property, :id=>'owner1'
    assert_response :success
    assert_template "preview_owner"
    assert_not_nil assigns(:target_profile)
    assert_nil assigns(:profile)
  end

  def test_property_should_301_to_buyer_lens_if_not_found
    get :property, :id=>'fake_id'
    assert_response 301
  end
end
