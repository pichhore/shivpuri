class PropertiesController < ApplicationController
  before_filter :store_location, :only => [:apply]
  after_filter :store_location, :only => [:list]
  
  filter_resource_access 
 
  add_crumb "Properties", '/'

  def index
    if !(params[:input] == "")
      input = params[:input].split(/\s+/)

      search = {}
      
      search[:address_country_name_or_address_city_or_address_state_or_address_street_name_or_title_or_description_like] = input
      search[:listed] = true
      
      if params[:searchby] == "highestrent"
        search[:descend_by_monthly_rental] = true
     elsif  params[:searchby] == "lowestrent"
         search[:ascend_by_monthly_rental] = true
      end
      results = Property.search(search)
      if params[:searchby] == "mostreviewes"
#       @properties = Property.most_liked(results.all).paginate :page => params[:page],:per_page => 20
       @properties = Property.most_reviewed(results.all).paginate :page => params[:page],:per_page => 20
      end
      @properties = results.paginate :page => params[:page],:per_page => 20

    end
    if current_user
      @selected_tab = "none"
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

  def show
   if current_user
      @properties = PropertyDoc.find_properties(params[:id])
      render :layout=>"new/application"
   else
      render :layout=>"new/external_user"
    end
  end

  def like_properties
    like_by_me = check_user_like_property
    unless  like_by_me
      @like = @property.like_properties.new( :user_id => current_user.id, :count => 1)
      if  @like.save
      end
    end 
     render :partial => "like_property", :collection => @like_properties
  end

  private

  def check_user_like_property
    @property.like_properties.each do|lp|
    if lp.user_id == current_user.id
      return true
    end
    end
    return false
  end

end
