require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper
include AuthenticatedSystem
def action_name() end

describe SessionsController do
  fixtures :users
  
  before do
    # FIXME -- sessions controller not testing xml logins 
    stub!(:authenticate_with_http_basic).and_return nil
  end    
  
  describe "logout_killing_session!" do
    before do
      login_as :john
      stub!(:reset_session)
    end
  end

  

  
end
