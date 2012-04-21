class PublicController < ApplicationController
  before_filter :load_profile, :only=>[:show]

  layout "application"

  # GET /public
  # GET /public.xml

  def index
    @profiles = Profile.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @profiles.to_xml }
    end
  end

  # GET /public/1
  # GET /public/1.xml
  def show
    respond_to do |format|
      format.html { render :action => "show_"+@profile.profile_type.permalink }
      format.xml  { render :xml => @profile.to_xml }
    end
  end
end
