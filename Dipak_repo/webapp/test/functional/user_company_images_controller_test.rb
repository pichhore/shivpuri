require File.dirname(__FILE__) + '/../test_helper'

class UserCompanyImagesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:user_company_images)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_user_company_image
    assert_difference('UserCompanyImage.count') do
      post :create, :user_company_image => { }
    end

    assert_redirected_to user_company_image_path(assigns(:user_company_image))
  end

  def test_should_show_user_company_image
    get :show, :id => user_company_images(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => user_company_images(:one).id
    assert_response :success
  end

  def test_should_update_user_company_image
    put :update, :id => user_company_images(:one).id, :user_company_image => { }
    assert_redirected_to user_company_image_path(assigns(:user_company_image))
  end

  def test_should_destroy_user_company_image
    assert_difference('UserCompanyImage.count', -1) do
      delete :destroy, :id => user_company_images(:one).id
    end

    assert_redirected_to user_company_images_path
  end
end
