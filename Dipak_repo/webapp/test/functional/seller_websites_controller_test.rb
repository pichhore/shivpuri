require File.dirname(__FILE__) + '/../test_helper'

class SellerWebsitesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:seller_websites)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_seller_website
    assert_difference('SellerWebsite.count') do
      post :create, :seller_website => { }
    end

    assert_redirected_to seller_website_path(assigns(:seller_website))
  end

  def test_should_show_seller_website
    get :show, :id => seller_websites(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => seller_websites(:one).id
    assert_response :success
  end

  def test_should_update_seller_website
    put :update, :id => seller_websites(:one).id, :seller_website => { }
    assert_redirected_to seller_website_path(assigns(:seller_website))
  end

  def test_should_destroy_seller_website
    assert_difference('SellerWebsite.count', -1) do
      delete :destroy, :id => seller_websites(:one).id
    end

    assert_redirected_to seller_websites_path
  end
end
