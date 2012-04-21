class StatesController < ApplicationController

  def index
#      @state_symbole = params[:state_id]
      @country = params[:country_id]
#       @states = params[:country_id] == "CA" ? State::NAMES : State::CANADA_NAMES
#      @states = State.sort_state(params[:country_id])
     render :partial => 'state_list' 
  end

  def db_state
    @country = params[:country_id]
    @states = State.find(:all,:conditions => ["name is not null"], :order=>:name)
    render :partial => 'db_state' 
  end 


  def get_user_states
    @country = params[:id]
    render :layout=>false
  end

  def get_property_states
    @country = params[:country_id]
    render :layout=>false
  end


end
