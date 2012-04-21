require File.dirname(__FILE__) + '/../test_helper'
require 'profile_view_controller'

# Re-raise errors caught by the controller.
class ProfileViewController; def rescue_action(e) raise e end; end

class ProfileViewControllerTest < Test::Unit::TestCase
  def setup
    @controller = ProfileViewController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_require_login
    viewer_profile = profiles(:buyer1)
    viewed_profile = profiles(:owner1)
    get :show, :id=>viewed_profile.id, :profile_id=>viewer_profile.id
    assert_redirected_to :controller=>"sessions", :action=>"new"
  end

  def test_should_show_owner_single_family
    login(users("quentin"))
    viewer_profile = profiles(:buyer1)
    viewed_profile = profiles(:owner1)
    assert_show_profile_success(viewer_profile, viewed_profile,"show_owner")
  end

  def test_should_show_buyer_single_family
    login(users("quentin"))
    viewer_profile = profiles(:owner1)
    viewed_profile = profiles(:buyer1)
    assert_show_profile_success(viewer_profile, viewed_profile,"show_buyer")
  end

  def test_should_show_owner_multi_family
    login(users("quentin"))
    viewer_profile = profiles(:buyer1)
    viewed_profile = profiles(:owner1)
    viewed_profile.set_profile_field(:property_type,"multi_family")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_owner")
  end

  def test_should_show_buyer_multi_family
    login(users("quentin"))
    viewer_profile = profiles(:owner1)
    viewed_profile = profiles(:buyer1)
    viewed_profile.set_profile_field(:property_type,"multi_family")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_buyer")
  end

  def test_should_show_owner_condo_townhome
    login(users("quentin"))
    viewer_profile = profiles(:buyer1)
    viewed_profile = profiles(:owner1)
    viewed_profile.set_profile_field(:property_type,"condo_townhome")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_owner")
  end

  def test_should_show_buyer_condo_townhome
    login(users("quentin"))
    viewer_profile = profiles(:owner1)
    viewed_profile = profiles(:buyer1)
    viewed_profile.set_profile_field(:property_type,"condo_townhome")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_buyer")
  end

  def test_should_show_owner_acreage
    login(users("quentin"))
    viewer_profile = profiles(:buyer1)
    viewed_profile = profiles(:owner1)
    viewed_profile.set_profile_field(:property_type,"acreage")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_owner")
  end

  def test_should_show_buyer_acreage
    login(users("quentin"))
    viewer_profile = profiles(:owner1)
    viewed_profile = profiles(:buyer1)
    viewed_profile.set_profile_field(:property_type,"acreage")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_buyer")
  end

  def test_should_show_owner_vacant_lot
    login(users("quentin"))
    viewer_profile = profiles(:buyer1)
    viewed_profile = profiles(:owner1)
    viewed_profile.set_profile_field(:property_type,"vacant_lot")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_owner")
  end

  def test_should_show_buyer_vacant_lot
    login(users("quentin"))
    viewer_profile = profiles(:owner1)
    viewed_profile = profiles(:buyer1)
    viewed_profile.set_profile_field(:property_type,"vacant_lot")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_buyer")
  end

  def test_should_show_owner_other
    login(users("quentin"))
    viewer_profile = profiles(:buyer1)
    viewed_profile = profiles(:owner1)
    viewed_profile.set_profile_field(:property_type,"other")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_owner")
  end

  def test_should_show_buyer_other
    login(users("quentin"))
    viewer_profile = profiles(:owner1)
    viewed_profile = profiles(:buyer1)
    viewed_profile.set_profile_field(:property_type,"other")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_buyer")
  end

  def test_should_not_create_profile_view_for_self
    login(users("quentin"))
    viewer_profile = profiles(:owner1)
    viewed_profile = profiles(:owner1)
    viewed_profile.set_profile_field(:property_type,"other")
    assert_show_profile_success(viewer_profile, viewed_profile,"show_owner", 0)
    profile_view = assigns(:profile_view)
    assert_nil profile_view
  end

  protected

  def assert_show_profile_success(viewer_profile, viewed_profile, template, diff_count=1)
    count = ProfileView.find_all_by_profile_id_and_viewed_by_profile_id(viewed_profile.id, viewer_profile.id).length
    get :show, :id=>viewed_profile.id, :profile_id=>viewer_profile.id
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}"
    assert_not_nil assigns(:profile)
    assert_not_nil assigns(:target_profile)
    assert_template template
    assert_equal count+diff_count, ProfileView.find_all_by_profile_id_and_viewed_by_profile_id(viewed_profile.id, viewer_profile.id).length
  end
end
