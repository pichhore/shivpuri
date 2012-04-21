require File.dirname(__FILE__) + '/../../test_helper'

class Admin::AlertTriggerTypesControllerTest < ActionController::TestCase

  
  def test_should_get_index
    login(users(:admin))
    get :index
    assert_response :success
    assert_not_nil assigns(:alert_trigger_types)
  end

  def test_should_get_new
    login(users(:admin))
    get :new
    assert_response :success
  end

  def test_should_create_alert_trigger_type
    login(users(:admin))
    assert_difference('AlertTriggerType.count') do
      post :create, :alert_trigger_type => { :name=>'name', :description=>'description', :method_name=>'method name' }
    end

    assert_redirected_to alert_trigger_type_path(assigns(:alert_trigger_type))
  end

  def test_should_show_alert_trigger_type
    login(users(:admin))
    get :show, :id => alert_trigger_types(:one).id
    assert_response :success
  end

  def test_should_get_edit
    login(users(:admin))
    get :edit, :id => alert_trigger_types(:one).id
    assert_response :success
  end

  def test_should_update_alert_trigger_type
    login(users(:admin))
    put :update, :id => alert_trigger_types(:one).id, :alert_trigger_type => { }
    assert_redirected_to alert_trigger_type_path(assigns(:alert_trigger_type))
  end

  def test_should_destroy_alert_trigger_type
    login(users(:admin))
    assert_difference('AlertTriggerType.count', -1) do
      delete :destroy, :id => alert_trigger_types(:one).id
    end

    assert_redirected_to alert_trigger_types_path
  end

end
