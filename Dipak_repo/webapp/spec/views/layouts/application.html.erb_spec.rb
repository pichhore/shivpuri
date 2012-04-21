require File.dirname(__FILE__) + '/../../spec_helper'

#~ describe "layouts/application.rhtml" do

  #~ before do
    #~ @user = mock_model(User, :new_record? => false, :name => "michael")
    #~ @profiles = [stub_model(Profile,:new_record? => false,:id => 123),stub_model(Profile,:new_record? => false,:id => 124)]
    #~ @community_stats = mock_model(CommunityStats,:property_count => 10, :active_buyers => 11).as_new_record
    #~ assigns[:order] = @order

    #~ assigns[:user] = @user
    #~ assigns[:profiles] = @profiles
    #~ assigns[:community_stats] = @community_stats  
  #~ end


  #~ it "should display Import Buyer Profile link" do
    #~ render "layouts/application.rhtml"
    #~ response.should have_tag("a", "/profiles/import")   
  #~ end  
  
#~ end