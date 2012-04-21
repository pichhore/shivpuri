require File.dirname(__FILE__) + '/../../spec_helper'

describe "profiles/import.rhtml" do

  it "should display a page to upload excel files" do
    render "profiles/import.rhtml"
   
    response.should have_tag("form[action='/profiles/import']") do
      with_tag("input[type=submit]")
    end
    
  end   
  
end