require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/alert_definitions_controller'

class Admin::AlertDefinitionsControllerTest < ActionController::TestCase
  
  def test_should_get_index
    login(users(:admin))
    get :index
    assert_response :success
    assert_not_nil assigns(:alert_definitions)
  end

  def test_should_get_new
    login(users(:admin))
    get :new
    assert_response :success
  end

  def test_should_create_alert_definition
    login(users(:admin))
    assert_difference('AlertDefinition.count') do
      post :create, :alert_definition => { :title=>'title',:message=>'message',:details=>'details',:alert_trigger_type=>alert_trigger_types(:one) }
    end

    assert_redirected_to alert_definition_path(assigns(:alert_definition))
  end

  def test_should_show_alert_definition
    login(users(:admin))
    get :show, :id => alert_definitions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    login(users(:admin))
    get :edit, :id => alert_definitions(:one).id
    assert_response :success
  end

  def test_should_update_alert_definition
    login(users(:admin))
    put :update, :id => alert_definitions(:one).id, :alert_definition => { :title=>'title',:message=>'message',:details=>'details',:alert_trigger_type=>alert_trigger_types(:one) }
    assert_redirected_to alert_definition_path(assigns(:alert_definition))
  end

  def test_should_destroy_alert_definition
    login(users(:admin))
    assert_difference('AlertDefinition.count', -1) do
      delete :destroy, :id => alert_definitions(:one).id
    end

    assert_redirected_to alert_definitions_path
  end
end
