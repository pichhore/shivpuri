require File.dirname(__FILE__) + '/../../spec_helper'

describe "account/profiles.rhtml" do

  before do
    @user = stub_model(User).as_new_record
    @profiles = [stub_model(Profile,:new_record? => false,:id => 123),stub_model(Profile,:new_record? => false,:id => 124)]
    @community_stats = mock_model(CommunityStats,:property_count => 10, :active_buyers => 11).as_new_record
    assigns[:order] = @order

    assigns[:user] = @user
    assigns[:profiles] = @profiles
    assigns[:community_stats] = @community_stats  
  end


  it "should display Import Buyer Profile link" do
    render "account/profiles.rhtml"
    response.should have_tag("a", "/profiles/#{@profiles.first.id}")   
  end   
  
end