require File.dirname(__FILE__) + '/../test_helper'

class BuyerUserImagesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:buyer_user_images)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_buyer_user_image
    assert_difference('BuyerUserImage.count') do
      post :create, :buyer_user_image => { }
    end

    assert_redirected_to buyer_user_image_path(assigns(:buyer_user_image))
  end

  def test_should_show_buyer_user_image
    get :show, :id => buyer_user_images(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => buyer_user_images(:one).id
    assert_response :success
  end

  def test_should_update_buyer_user_image
    put :update, :id => buyer_user_images(:one).id, :buyer_user_image => { }
    assert_redirected_to buyer_user_image_path(assigns(:buyer_user_image))
  end

  def test_should_destroy_buyer_user_image
    assert_difference('BuyerUserImage.count', -1) do
      delete :destroy, :id => buyer_user_images(:one).id
    end

    assert_redirected_to buyer_user_images_path
  end
end
