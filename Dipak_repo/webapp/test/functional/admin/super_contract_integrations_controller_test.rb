require 'test_helper'

class Admin::SuperContractIntegrationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_super_contract_integrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create super_contract_integration" do
    assert_difference('Admin::SuperContractIntegration.count') do
      post :create, :super_contract_integration => { }
    end

    assert_redirected_to super_contract_integration_path(assigns(:super_contract_integration))
  end

  test "should show super_contract_integration" do
    get :show, :id => admin_super_contract_integrations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => admin_super_contract_integrations(:one).to_param
    assert_response :success
  end

  test "should update super_contract_integration" do
    put :update, :id => admin_super_contract_integrations(:one).to_param, :super_contract_integration => { }
    assert_redirected_to super_contract_integration_path(assigns(:super_contract_integration))
  end

  test "should destroy super_contract_integration" do
    assert_difference('Admin::SuperContractIntegration.count', -1) do
      delete :destroy, :id => admin_super_contract_integrations(:one).to_param
    end

    assert_redirected_to admin_super_contract_integrations_path
  end
end
