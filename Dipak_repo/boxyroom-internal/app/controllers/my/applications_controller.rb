class My::ApplicationsController < ApplicationController
  before_filter :require_user

  filter_resource_access :nested_in => :properties
  
  def show
    #@application = current_user.applications.find(params[:id])
    @selected_tab = "Properties"
    render :layout=>"new/application"
  end

  def approve
    @application.approved_at = Time.now

    Application.transaction do
      @application.approve!
      @application.save!
    end

    flash[:notice] = "Application successfully approved."
    redirect_to my_property_path(@application.property)
  end

  def reject
    @application.reject!

    flash[:notice] = "Application successfully rejected."
    redirect_to my_property_path(@application.property)
  end

end
