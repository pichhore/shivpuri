class ProfileMatchesController < ApplicationController
  before_filter :login_required
  before_filter :load_profile
  before_filter :check_profile_ownership

  PROFILES_PER_PAGE = 10

  # GET /profile_matches
  # GET /profile_matches.xml
  def index
    @retail_buyer_profile = @profile if (params[:from] && params[:from] == "buyer_leads" )
    @page_number = (params[:page_number] || "1").to_i
    @result_filter = (params[:result_filter] || "all")
    default_sort_type = @profile.owner? ? "has_profile_image,desc" : "privacy,desc"
    @sort = (params[:sort] || default_sort_type)
    @sort_type = @sort.split(',')[0]
    @sort_order = @sort.split(',')[1]
    @sort_string = "#{@sort_type} #{@sort_order}"
    @offset = @page_number == 1 ? nil : (@page_number-1) * PROFILES_PER_PAGE
    @listing_type = params[:listing_type] || "all"
    @listing_type = "all" if @listing_type.empty?

    # Fetch results, with custom pagination support
    @profiles,@total_profiles_fetched,@total_pages = MatchingEngine.get_matches(:profile=>@profile, :offset=>@offset, :result_filter=>@result_filter, :number_to_fetch=> PROFILES_PER_PAGE, :sort=>@sort_string, :listing_type=>@listing_type, :use_cache => true)

    unless (@profile.is_wholesale_profile? or @profile.is_wholesale_owner_finance_profile?)
      offset,number_to_fetch = Profile.get_limit_and_offset(@total_profiles_fetched,@page_number,PROFILES_PER_PAGE)
      #Near Match
      if @result_filter=='all' || @result_filter=='new'
        @near_profiles,@near_total_profiles,@near_total_pages = MatchingEngine.get_matches(:profile=>@profile, :offset=>offset, :result_filter=>@result_filter, :number_to_fetch=> number_to_fetch, :sort=>@sort_string, :listing_type=>@listing_type, :use_cache => true, :near_match => true)
      else
        @near_profiles,@near_total_profiles,@near_total_pages = NearMatchingEngine.get_near_matches(:profile=>@profile, :offset=>offset, :result_filter=>@result_filter, :number_to_fetch=> number_to_fetch, :sort=>@sort_string, :listing_type=>@listing_type)
      end
    else
      @near_profiles,@near_total_profiles,@near_total_pages = [], 0, 0
    end

    if @result_filter=='all' || @result_filter=='new' || @result_filter=='favorites'
    @total_pages = ( (@total_profiles_fetched.to_i + @near_total_profiles.to_i) / PROFILES_PER_PAGE.to_i)
    @total_pages += 1 if ((@total_profiles_fetched.to_i + @near_total_profiles.to_i) % PROFILES_PER_PAGE.to_i) != 0
    @total_pages = 1 if @total_pages == 0
    end
    # Prime the profile models for their display purpose
    @profiles.each { |profile| profile.prepare_for_match_display(@profile, profile_profile_view_path(@profile, profile))}

    # prepare the map
    @map = ZipCodeMap.prepare_map(@profiles.first.zip_code.to_s) unless @profiles.first == nil
    @map = ZipCodeMap.prepare_map(@profile.zip_code.to_s) if @profiles.first == nil

    @boundary_overlays = ZipCodeMap.prepare_boundary_overlays(@profile.zip_code.to_s)

    @marker_overlays = ZipCodeMap.prepare_marker_overlays(@profiles, :context_profile=>@profile,  :return_params=>encode_return_dashboard_variables) unless @profiles.first == nil
    @marker_overlays = [] if @profiles.first == nil

    respond_to do |format|
      format.html  do
        # if we need some special javascript to update the buyer map, change this call to render a different partial
        # with this call embeded within
        render :partial=>"#{@profile.profile_type.permalink_to_generic_page}_matches" and return if request.xhr?
      end
      format.xml   { render :xml => @profiles.to_xml }
      format.json  { render :json => @profiles.to_json(:only=>[:id], :methods =>[:display_name, :display_type, :display_description, :display_features, :display_price, :display_is_favorite, :display_details_uri]) }
    end
  end

  # GET /profile_matches/1
  # GET /profile_matches/1.xml
  def show
    @profile_match = ProfileMatch.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @profile_match.to_xml }
    end
  end

  # GET /profile_matches/new
  def new
    @profile_match = ProfileMatch.new
  end

  # GET /profile_matches/1;edit
  def edit
    @profile_match = ProfileMatch.find(params[:id])
  end

  # POST /profile_matches
  # POST /profile_matches.xml
  def create
    @profile_match = ProfileMatch.new(params[:profile_match])

    respond_to do |format|
      if @profile_match.save
        flash[:notice] = 'ProfileMatch was successfully created.'
        format.html { redirect_to profile_profile_match_url(@profile_match) }
        format.xml  { head :created, :location => profile_profile_match_url(@profile_match) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile_match.errors.to_xml }
      end
    end
  end

  # PUT /profile_matches/1
  # PUT /profile_matches/1.xml
  def update
    @profile_match = ProfileMatch.find(params[:id])

    respond_to do |format|
      if @profile_match.update_attributes(params[:profile_match])
        flash[:notice] = 'ProfileMatch was successfully updated.'
        format.html { redirect_to profile_profile_match_url(@profile_match) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile_match.errors.to_xml }
      end
    end
  end

  # DELETE /profile_matches/1
  # DELETE /profile_matches/1.xml
  def destroy
    @profile_match = ProfileMatch.find(params[:id])
    @profile_match.destroy

    respond_to do |format|
      format.html { redirect_to profile_profile_matches_url }
      format.xml  { head :ok }
    end
  end
end