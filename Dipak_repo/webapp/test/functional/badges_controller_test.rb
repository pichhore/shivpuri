require File.dirname(__FILE__) + '/../test_helper'

class BadgesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:badges)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_badge
    assert_difference('Badge.count') do
      post :create, :badge => { }
    end

    assert_redirected_to badge_path(assigns(:badge))
  end

  def test_should_show_badge
    get :show, :id => badges(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => badges(:one).id
    assert_response :success
  end

  def test_should_update_badge
    put :update, :id => badges(:one).id, :badge => { }
    assert_redirected_to badge_path(assigns(:badge))
  end

  def test_should_destroy_badge
    assert_difference('Badge.count', -1) do
      delete :destroy, :id => badges(:one).id
    end

    assert_redirected_to badges_path
  end
end
