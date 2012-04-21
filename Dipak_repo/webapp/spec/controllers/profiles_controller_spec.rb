require File.dirname(__FILE__) + '/../spec_helper'

describe ProfilesController do
  include AuthenticatedSystem
  before :each do
   @current_user = mock_model(User, :id => 1)
   controller.stub!(:current_user).and_return(@current_user)
   controller.stub!(:login_required).and_return(:true)
  end
  fixtures :users
  
  #test case for import action
  it 'GET/import should be successful' do
    get :import
    response.should be_success
    response.should render_template('import')
  end
  
  #~ it 'should test for importing new buyers csv file' do
    #~ post :import
    #~ p response.body
  #~ end  
end
