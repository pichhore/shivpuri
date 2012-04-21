class ConfigController < ApplicationController
 before_filter :secrete_key_required

  def index
    render :json => {  :login_url => REIMATCHER_URL+"login", :logout_url =>REIMATCHER_URL+"logout", :sales_url => REIMATCHER_URL+"upgrade_user_type/user_plan", :cookie_name =>"user_id" } 
  end

end
