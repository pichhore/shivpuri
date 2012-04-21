require 'fastercsv'

class ProfilesController < ApplicationController

  uses_yui_editor(:only => ["edit", "new", "update", "create"])
  before_filter :admin_access_required, :only=>:index
  before_filter :login_required, :except=>[:new, :new_buyer_zipselect, :new_buyer_agent_zipselect, :create, :multi_zip_select, :multi_zip_select_latest, :select_multiple_areas_on_map, :update_notification, :get_city_for_province, :single_property_webpage, :delete_deal]
  before_filter :login_required, :except=>[:new, :new_buyer_zipselect, :new_buyer_agent_zipselect, :create, :multi_zip_select, :multi_zip_select_latest, :select_multiple_areas_on_map, :update_notification, :get_city_for_province, :single_property_webpage, :get_county_for_state, :delete_deal]
  before_filter :load_profile_type, :only=>[:new, :new_buyer_zipselect, :new_buyer_agent_zipselect, :create]
  before_filter :load_profile, :only=>[:show, :edit, :edit_zipcodes, :update, :update_zip_codes, :delete_confirm, :destroy, :mark_as_spam, :edit_private_display_name, :update_private_display_name, :edit_notification, :update_notification, :profile_contact, :update_profile_contact]
  before_filter :check_profile_ownership, :only=>[:show, :edit, :edit_zipcodes, :update, :update_zip_codes, :delete_confirm, :destroy, :edit_private_display_name, :update_private_display_name, :profile_contact, :update_profile_contact]
  before_filter :check_zip, :only => [:update_zipcodes]

  layout "application"

  PROFILES_PER_PAGE = 10

  # GET /profiles
  # GET /profiles.xml
  # James: This is an admin action to list all profiles in the system (future)
  def index
    @profiles = Profile.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @profiles.to_xml }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml
  def show
    @page_number = (params[:page_number] || "1").to_i
    @page_number = 1 if @page_number == 0
    @result_filter = (params[:result_filter] || "all")
    @result_filter = "all" if @result_filter.empty?
    @listing_type = (params[:listing_type] || "all")
    @listing_type = "all" if @listing_type.empty?
    @message_filter = (params[:message_filter] || "All")
    if @result_filter == "messages"
      default_sort_type = "created_at,desc"
    else
      default_sort_type = @profile.owner? ? "has_profile_image,desc" : "privacy,desc"
    end
    @sort = (params[:sort] || default_sort_type)
    @sort = default_sort_type if @sort.empty?
    @sort_type = @sort.split(',')[0]
    @sort_order = @sort.split(',')[1]
    @sort_string = "#{@sort_type} #{@sort_order}"

    # determine tab index within dashboard based on the result_filter, use from constructor of controller
    if @profile.buyer? or @profile.buyer_agent?
      # buyer: all: 0, new:1, favorites:2, viewed_me:3, messages:4
      @tab_index = 0 if @result_filter == "all"
      @tab_index = 1 if @result_filter == "new"
      @tab_index = 2 if @result_filter == "favorites"
      @tab_index = 3 if @result_filter == "viewed_me"
      @tab_index = 4 if @result_filter == "messages"
    else
      # owner: all: 0, new:1, viewed_me:2, messages:3
      @tab_index = 0 if @result_filter == "all"
      @tab_index = 1 if @result_filter == "new"
      @tab_index = 2 if @result_filter == "viewed_me"
      @tab_index = 3 if @result_filter == "messages"
    end
    # Fetch results, with custom pagination support
    @offset = @page_number == 1 ? nil : (@page_number-1) * PROFILES_PER_PAGE
    if @result_filter == "messages"
      @profile_message_recipients, @total_pages = ProfileMessageRecipient.find_distinct_for(@profile, @offset, PROFILES_PER_PAGE, "pmr.viewed_at ASC, pm.created_at DESC", @message_filter, @listing_type)
    else      
      @profiles, @total_profiles_fetched, @total_pages = MatchingEngine.get_matches(:profile=>@profile, :offset=>@offset, :result_filter=>@result_filter, :number_to_fetch=> PROFILES_PER_PAGE, :sort=>@sort_string, :listing_type=>@listing_type, :use_cache => true)
     # @profiles,@total_profiles_fetched,@total_pages  = MatchingEngine.get_matches(:profile=>@profile, :offset=>@offset, :result_filter=>@result_filter, :number_to_fetch=> PROFILES_PER_PAGE, :sort=>@sort_string, :listing_type=>@listing_type)

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
      @total_pages = ( (@total_profiles_fetched.to_i + @near_total_profiles.to_i) / PROFILES_PER_PAGE.to_i)
      @total_pages += 1 if ((@total_profiles_fetched.to_i + @near_total_profiles.to_i) % PROFILES_PER_PAGE.to_i) != 0
      @total_pages = 1 if @total_pages == 0
      # prepare the map
      @profile.zip_code = "B2S 1L9" if @profile.zip_code.blank?
      @map = ZipCodeMap.prepare_map(@profiles.first.zip_code.to_s) unless @profiles.first == nil
      @map = ZipCodeMap.prepare_map(@profile.zip_code.to_s) if @profiles.first == nil

      @boundary_overlays = ZipCodeMap.prepare_boundary_overlays(@profile.zip_code.to_s)

      @marker_overlays = ZipCodeMap.prepare_marker_overlays(@profiles, :context_profile=>@profile, :return_params=>encode_return_dashboard_variables) unless @profiles.first == nil
      @marker_overlays = [] if @profiles.first == nil
    end


    # prepare the fields form if this is a buyer
    if @profile.buyer? or @profile.buyer_agent?
      @fields = ProfileFieldForm.create_form_for(@profile.profile_type)
      @fields.from_profile_fields(@profile.profile_fields)
    end

    
     @total_profiles = @profile.count_all
   # pmc = ProfileMatchesCount.find_by_profile_id(@profile.id)
   # unless pmc.nil?
   #   @total_profiles = pmc.count
   # else
   #   @total_profiles = 0
   # end
    @match_count = @profile.match_count_text(@total_profiles_fetched, @listing_type)
    # indicate that we're using popups on thumbnails
    @uses_yui_lightbox = true
    
    respond_to do |format|
      format.html { render :partial=>"buyer_matches" and return if request.xhr?
        render :action => "show_"+@profile.profile_type.permalink_to_generic_page }
      format.xml  { render :xml => @profile.to_xml }
    end
  end

  # GET /profiles/new
  def new
    # allow the buyer to view a map and select the zip they want
    # if the zipcode isn't passed into this action
    # Note: owners skip this step and go right to profile setup
    $parameterss = params
    if (params[:country].blank? or params[:country] == "US") and !params[:zip_code] and @profile_type.buyer?
      redirect_to :action => "new_buyer_zipselect", :id=>params[:id] and return
    end
    if !params[:zip_code] and @profile_type.buyer_agent?
      redirect_to :action => "new_buyer_agent_zipselect", :id=>params[:id] and return
    end
    @user = User.new
    @fields = ProfileFieldForm.create_form_for(@profile_type.permalink)
    @fields.privacy = "public"
    @fields.country = params[:country] unless params[:country].blank?
    @fields.state = params[:state] unless params[:state].blank?
    @fields.city = params[:city][:city] unless params[:city].blank?
    @wholesale_flag = true unless params[:wholesale].blank?
    @owner_finance_flag = true unless params[:owner_finance].blank?
    county_string = String.new
    if !params[:county].blank? and !params[:county][:county].blank?
      params[:county][:county].each do |county|
        county_string = county and next if county_string.blank?
        county_string = county_string.to_s+","+county.to_s
      end
    end 
    @fields.county = county_string
    @fields.zip_code = params[:zip_code]
    if !params[:city].blank? and @fields.zip_code.blank?
          @fields.zip_code = params[:zip_code].blank? ? (Zip.find(:first, :conditions => ["city = ? and country = ? and state = ?",params[:city][:city], params[:country], params[:state]]).zip) : params[:zip_code]
#            @fields.zip_code = params[:zip_code].blank? ? (Zip.find(:first, :conditions => ["city = ?",params[:city][:city]]).zip) : params[:zip_code]
    end
    if !params[:seller_property_profile_id].blank?
      @owner_finance_flag = true
      set_profile_field_values (params[:seller_property_profile_id])
    end 
    render :action => "new_"+@profile_type.permalink_to_page
  end


  def single_property_webpage
    begin
      @profil = Profile.find_by_random_string(params[:property_id])
      if @profil.nil?
        render :layout => false, :template => "profiles/property_sold" 
      elsif !@profil.deleted_at.nil?
        render :layout => false, :template => "profiles/property_sold"
      else
        @random_string = params[:property_id]
        render :layout => false
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      #handle_error("Internal error - could not mark as spam",exp) and return
    end   
  end


  def new_buyer_zipselect    
    @zip_code = params[:zip_code] || ''
    @states = State.find(:all,:conditions => ["name is not null and country = ?",params[:country_id]], :order=>:name)
    @cities = Array.new
    @counties = Array.new
    # use ip address to guess location
    geoip = GeoIP.new(RAILS_ROOT + '/public/geoip/GeoLiteCity.dat').city( self.request.remote_ip )
    geoip_zip_code = geoip[ 8 ] if !geoip.nil? && !geoip[ 8 ].blank?

    if !geoip_zip_code.nil?
      @directions_available = Zip.find(:all, :conditions => ["city LIKE ? and state LIKE ? and direction is not null", geoip[ 7 ], geoip[ 6 ]])
    else
      @directions_available = Zip.find(:all, :conditions => ["city LIKE 'Austin' and state LIKE 'TX' and direction is not null"])
    end

    @zoom_level = 11
    @center_zip_code = Zip.find(:all, :conditions => {:zip => geoip_zip_code }) unless geoip_zip_code.nil?
    if geoip_zip_code.nil? || @center_zip_code.blank?
      geoip_zip_code = '69130'
      @zoom_level = 4
      @center_zip_code = Zip.find(:all, :conditions => {:zip => geoip_zip_code })
    end
    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select_latest'
    @map_params = ZipCodeMap.prepare_map_params(geoip_zip_code, :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
  end
  
  def get_city_for_province
    if !params[:state_id].blank? 
      @cities = Zip.find(:all, :conditions=>["country = ? and state = ? ","ca" , params[:state_id]], :order => "city").map(&:city).uniq
      @cities.blank? ? Array.new : @cities  
    else
      @cities = Array.new
    end     
     render :layout=>false
  end  

  def get_county_for_state
    state = State.find(:first, :conditions => ["state_code = ?",params[:state_id]])
    unless state.blank? 
      @counties = County.get_counties_for_state(state.id).map(&:name).uniq
      @counties.blank? ? Array.new : @counties  
    else
      @counties = Array.new
    end     
     render :layout=>false
  end  

  def new_buyer_agent_zipselect
    @zip_code = params[:zip_code] || ''

    # use ip address to guess location
    geoip = GeoIP.new( RAILS_ROOT + '/public/geoip/GeoLiteCity.dat' ).city( self.request.remote_ip )
    
    geoip_zip_code = geoip[ 8 ]
    geoip_zip_code = '69130' if geoip_zip_code.empty?
    
    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select'

    @map = ZipCodeMap.prepare_map(geoip_zip_code, :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
    @boundary_overlays = ZipCodeMap.prepare_boundary_overlays(@zip_code)
    @js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value")
  end

  # GET /profiles/1;edit
  def edit
    if params["dgb"]=="1" && (@profile.profile_type.permalink == "buyer" || @profile.profile_type.permalink == "buyer_agent") 
      pfei_array = ProfileFieldEngineIndex.find(:all, :conditions => {:profile_id => @profile.id})
      profile_field_cd = ProfileField.find(:first, :conditions => ["profile_id=? AND profile_fields.key LIKE ?",@profile.id, 'contract_end_date'])
      if profile_field_cd.value.blank?
        profile_field_cd.update_attribute('value', (Date.today + 180).to_s(:db))
      else
        profile_field_cd.update_attribute('value',(profile_field_cd.value.to_date + 180).to_s(:db))
      end
      unless pfei_array.empty?
        pfei_array.each do |pfei|
          pfei.update_attributes!(:contract_end_date => (profile_field_cd.value.to_date).to_s(:db))
        end
      end
    flash.now[:notice] = "Your contract period has been extended for another 180 days" 
    end
    profile_type = @profile.profile_type
    @fields = ProfileFieldForm.create_form_for(profile_type.permalink)
    @fields.from_profile_fields(@profile.profile_fields)
    # Fix to avoid exception. Need to verify why receiving nil here
    @fields.contract_end_date = ProfileFieldEngineIndex.contract_end_date(@profile.id).strftime('%m/%d/%Y') if ProfileFieldEngineIndex.contract_end_date(@profile.id)
    @fields.description = @fields.description
    if (@profile.investment_type_id == 1 or @profile.investment_type_id == 3)
      @owner_finance_flag = true
    end
    if(@profile.investment_type_id == 2 or @profile.investment_type_id == 3)
      @wholesale_flag = true
    end

    render :action => "edit_"+profile_type.permalink_to_generic_page
  rescue  Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    handle_error("Error updating your contract date",exp) and return
  end
  
  # GET /profiles/1;edit_zipcodes
  def edit_zipcodes

    @zip_code = params[:zip_code] || @profile.zip_code
    @state = params[:state] || @profile.state
    state = State.find(:first, :conditions => ["state_code = ?",@state])
    unless state.blank? 
      @counties = County.get_counties_for_state(state.id).map(&:name).uniq
      @counties.blank? ? Array.new : @counties.map { |county| [county, county]  }  
    else
      @counties = Array.new
    end
#     @profile_counties = params[:zip_code] || @profile.county
    @profile_counties_array = Array.new 
    @profile_counties_array = @profile.county.split(",") if @profile.county.present?
    if (@profile.investment_type_id == 1 or @profile.investment_type_id == 3)
      @owner_finance_flag = true
    end
    if(@profile.investment_type_id == 2 or @profile.investment_type_id == 3)
      @wholesale_flag = true
    end
    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select_latest'
    @map_params = ZipCodeMap.prepare_map_params('69130', :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
    @coun  = params[:coun].blank? ? @profile.country.upcase : params[:coun]
     @zip_code = '69130' if @profile.country == "CA" and @coun == "US"
#     if ((params[:coun].blank? and @profile.country == "US") or params[:coun] == "US") and !@zip_code.blank?
    if (@coun == "US") and !@zip_code.blank?
      if @profile.owner?
        @zip_code = @zip_code.split(/[^0-9]+/).first
      end
  
      profile_zip  = @profile.country == "CA" ? ((!params[:coun].blank? and params[:coun] == "US") ? '69130' : @zip_code) : ((!params[:coun].blank? and params[:coun]) == "CA" ? 'G0X 2Z0' : @zip_code)
  
  
      click_route = url_for :controller => 'profiles', :action => @profile.owner? ? 'single_zip_select' : 'multi_zip_select'
      if @profile.country == "CA" and @coun == "US"
        @map = ZipCodeMap.prepare_map(profile_zip, :click_route => click_route, :zipcodes_js_source => "$('zip_code').value", :zoom_level => 4)
      else
        @map = ZipCodeMap.prepare_map(profile_zip, :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
      end
      @boundary_overlays = ZipCodeMap.prepare_boundary_overlays(@zip_code)
      @js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value") unless @profile.owner?
    else
      @state = params[:state] || @profile.state
      @cities = @profile.country == "US" ? Zip.find(:all, :conditions=>["state = ? and country = ?", @state, "CA"], :order => "city").map(&:city).uniq : Array.new
    end
  end

  def single_zip_select
    zip = ZipCodeMap.find_zip_for_coords( params[:lat].to_f, params[:long].to_f )
    boundary_overlays = ZipCodeMap.prepare_boundary_overlays( zip.zip )

    render :update do |page|
      page << "$('zip_code').value = '" + zip.zip + "';"
      page << "map.clearOverlays();"

      boundary_overlays.each do |overlay|
        page << "map.addOverlay( overlay =" + overlay.to_javascript() + ")"
      end
    end
  end

  def multi_zip_select
    zip_select = ZipCodeMap.find_zip_for_coords( params[:lat].to_f, params[:long].to_f )

    if zip_select.nil?
      zip = ""
    else
      zip = zip_select.zip
    end 
    @directions_available = Zip.find(:all, :conditions => ["zip LIKE ? and direction is not null", zip])

    ziplist = params[:zipcodes].blank? ? "" : params[:zipcodes]
    # check to see if list already contains zip
    if ziplist.include? zip then
      # don't remove last zip
      if ziplist.include? ',' then
        # remove from list
        zipset = ziplist.split(/[^0-9]+/)
        ziplist = ''

        zipset.each do |z|
          unless z.include? zip then
            ziplist += ',' unless ziplist.size == 0
            ziplist += z
          end
        end
      end
    elsif ziplist.empty?
      ziplist = "#{zip}"
    else
      # add to list
      ziplist = params[:zipcodes] + ',' + zip
    end

    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select'

    boundary_latlngs = ZipCodeMap.prepare_boundary_overlays(ziplist)
    js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value")

    render :update do |page|
      page << "$('zip_code').value = '" + ziplist + "';"
      page << "map.clearOverlays();"

      # Hiding & displaying the quick links
      if @directions_available.blank? or @directions_available==0
        page.hide 'direction_links'
      else
        page.show 'direction_links'  
        page.replace_html 'direction_links', :partial => 'directional_links'
      end
      
      boundary_latlngs.each do |overlay|
        page << "map.addOverlay( overlay =" + overlay.to_javascript() + ")"
        page << "GEvent.addListener( overlay, 'click', " + js + ")"
      end
    end
  end
   
  def multi_zip_select_latest
    zip_select = ZipCodeMap.find_zip_for_coords( params[:lat].to_f, params[:long].to_f )

    if zip_select.nil?
      zip = ""
    else
      zip = zip_select.zip
    end 
    @directions_available = Zip.find(:all, :conditions => ["zip LIKE ? and direction is not null", zip])

    ziplist = params[:zipcodes].blank? ? "" : params[:zipcodes]
    # check to see if list already contains zip
    if ziplist.include? zip then
      # don't remove last zip
      if ziplist.include? ',' then
        # remove from list
        zipset = ziplist.split(/[^0-9]+/)
        ziplist = ''

        zipset.each do |z|
          unless z.include? zip then
            ziplist += ',' unless ziplist.size == 0
            ziplist += z
          end
        end
      end
    elsif ziplist.empty?
      ziplist = "#{zip}"
    else
      ziplist = params[:zipcodes] + ',' + zip
    end

    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select'

    boundary_latlngs = ZipCodeMap.prepare_boundary_latlngs(ziplist)
    js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value")

    render :update do |page|
      page << "$('zip_code').value = '" + ziplist + "';"
      if @directions_available.blank? or @directions_available==0
#         page.hide 'direction_links'
      else
        page.show 'direction_links'  
        page.replace_html 'direction_links', :partial => 'directional_links'
      end
    
      boundary_latlngs.each{ |zip, boundary|
        if !params[:zipcodes].split(',').include?(zip.zip)
        page << "var latlngs = [];" 
        boundary.each{ |latlng|
          page << "latlngs.push(new google.maps.LatLng(#{latlng.first}, #{latlng.last}));"
        }
        page << "var polygon = new google.maps.Polygon({ paths: latlngs, strokeColor: '#888888', strokeOpacity: 0.85, strokeWeight: 4, fillColor: '#CC6600', fillOpacity: 0.25 });"
        page << "polygon.setMap(map);"

        page << "google.maps.event.addListener(polygon, 'click', function(){
          this.setMap(null);
          $('zip_code').value = $('zip_code').value.split(/,/).without(#{zip.zip}).toString();          
        });"
        end
      }
    end
  end

  def delete_confirm
    # use a separate model for delete than the profile that is loaded by the before_filter
    @profile_form = Profile.new
    @profile_delete_reasons = ProfileDeleteReason.find_for_profile(@profile)
  end
  
  # POST /profiles
  # POST /profiles.xml
  def create
    # DEBUG:
    #    render :text=>"<PRE>#{YAML::dump(params["fields"])}</PRE>" and return
    #    render :text => @profile_type.inspect and return
    # 1. Capture fields from the request into a form object
    
    #if !@profile_type.blank? && (@profile_type.permalink == "buyer" || @profile_type.permalink == "buyer_agent")
     # if !(params.has_key?( "owner_finance") || params.has_key?("wholesale"))
      #    flash[:error] = "Please select Investment Type"
       #   redirect_to new_profile_path($parameterss) and return
      #end
   # end

    @fields = ProfileFieldForm.create_form_for(@profile_type.permalink)
    if !@profile_type.blank? && (@profile_type.permalink == "buyer" || @profile_type.permalink == "buyer_agent")
      params['fields']['contract_end_date'] = (Date.today + 180).to_s(:db) unless params['fields'].blank?
    end
    @fields.from_hash(params['fields'])
    @wholesale_flag = true unless params[:wholesale].blank?
    @owner_finance_flag = true unless params[:owner_finance].blank?
    if !@profile_type.blank? && (@profile_type.permalink == "buyer" || @profile_type.permalink == "buyer_agent")
      if (params[:fields][:first_name].blank?)
            flash.now[:error] = "first name can't be blank"
            render :action => "new_"+@profile_type.permalink_to_page and return
      end
      if (params[:fields][:last_name].blank?)
            flash.now[:error] = "last name can't be blank"
            render :action => "new_"+@profile_type.permalink_to_page and return
      end
    end
    #@fields.from_hash(params['fields'])
    
    # 1a. Capture user account details

    if logged_in?
      @user = current_user
    else
      @user = User.new(params['user'])
      @user.login = @user.email
      @user.profile_type_at_registration = @profile_type
    end

    if (params[:wholesale].blank? && params[:owner_finance].blank?)
      @uncheck_flag = true
      flash.now[:error] = "Please select Investment Type"
      render :action => "new_"+@profile_type.permalink_to_page and return
    end
    validated_wholesale_owner_finance_values
    if !@fields.county.blank? and @fields.zip_code.blank?
      next_flag = false
      @fields.county.split(",").each do |coun|
        pro_coun = County.find(:first, :conditions => ["name = ?",coun])
        next if pro_coun.blank?
        pro_zip = Zip.find(:first, :conditions => ["county_id = ?",pro_coun.id])
        next if pro_zip.blank?
        @fields.zip_code, next_flag = pro_zip.zip, true
        break 
      end
      unless next_flag
        flash[:notice] = "Please choose appropriate Zip Code" 
        #return false
        redirect_to "buyer_websites/edit_buying_areas/#{params[:id]}"
        return false
      end
    end

    if @profile_type.owner? and !params[:profile].blank?
      @is_profile_contact, @is_profile_contact_phone = true, true
      @profile_contact_name = params[:profile][:contact_name]
      @profile_contact_phone = params[:profile][:contact_phone]
      flash[:profile_contact_name] = "Can't be blank"
      @is_profile_primary_contact_blank = (@profile_contact_phone.blank? or @profile_contact_name.blank?) ? true : false
    end

    # 2. Validate general fields and fields based on the property type
    if @fields.valid? && @fields.valid_for_property_type? && !@is_profile_primary_contact_blank

      # 3. Validate user account
      if logged_in? or @user.valid?
        # 4. Construct a profile and attach fields
        @profile = Profile.new
        @profile.investment_type_id = @fields.investment_type_id
        @profile.profile_type = @profile_type
        @profile.contact_name = @profile_contact_name.to_s
        @profile.contact_phone = @profile_contact_phone.to_s
        if !@profile_type.blank? && (@profile_type.permalink == "buyer" || @profile_type.permalink == "buyer_agent")
          if !params[:nickname].blank?
            @profile.profile_nickname = params[:nickname]
            profile_price_value= @profile.is_owner_finance_profile? ? @fields.max_dow_pay : @fields.max_purchase_value
            @profile.private_display_name = sprintf "%s, %s, %s", params[:nickname], @profile.investment_type.name, profile_price_value
          else
            profile_price_value= @profile.is_owner_finance_profile? ? @fields.max_dow_pay : @fields.max_purchase_value
             @profile.private_display_name = sprintf "%s, %s, %s", params[:fields][:first_name], @profile.investment_type.name, profile_price_value
          end
        end
#         @profile.county = @fields.county unless @fields.county.blank?
        @profile.country = @fields.country unless @fields.country.blank?
        @profile.state = @fields.state unless @fields.state.blank?
        @profile.city = @fields.city unless @fields.city.blank?
        @profile.profile_fields = @fields.to_profile_fields
        @profile.user = @user
        @profile.generate_name
        @profile.zip_code = params[:zip_code]
        # 5. Save account and profile, generate confirmation email for new account
        begin
          Profile.transaction do
            @user.profiles << @profile
            @profile.save! if current_user
            @user.save! unless current_user
	    #Posting Seller Property profile to the market place
            if !params[:seller_property_profile_id].blank? and !@profile.new_record?
              SellerPropertyProfile.save_seller_lead_mapping(params[:seller_property_profile_id],@profile.id) 
              create_seller_engagement_infos_for_publish_seller_property
              @profile.update_seller_property_profile unless @profile.seller_property_profile.blank?
	    end
	    log_activity(:activity_category_id=>'cat_acct_created', :user_id => @user.id, :session_id => request.session_options[:id]) unless current_user
            user_id = @user.id unless logged_in?
            user_id = current_user.id if logged_in?
            log_activity(:activity_category_id=>'cat_prof_created', :user_id => user_id, :profile_id => @profile.id, :session_id=>request.session_options[:id], :profile_name => @profile.profile_name)

            if logged_in? && @user.auto_syndication && params[:id] == "owner"
              @property_fields = params['fields']
              if @property_fields['privacy'] == "public"
                @property_fields.delete("privacy")
                SyndicateProperty.save_manual_syndicate_property(@profile.id, current_user)
                @site_users = SiteUser.find_all_by_user_id(@user.id, :select => 'site_users.site_id, site_users.id')
                if @site_users.empty?
                  syndicator_listing
                  @xml_output["sites"].each{ |site| ProfileSite.add(@profile.id, site["id"]) } if !@xml_output["sites"].nil?
                else
                  @site_users.each{ |site_user| ProfileSite.add(@profile.id, site_user.site_id ) } if !@site_users.nil?
                end                
              end
            end
          end
        rescue  Exception => exp
          ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
          handle_error("Error saving your new profile",exp) and return
        end

        if logged_in?
          if @profile_type.owner? || @profile_type.seller_agent?
            #redirect_to :controller=>"account", :action=>"add_owner_created" and return if @profile_type.owner?
            #redirect_to profile_profile_images_url(@profile)+'?new=true' and return if @profile_type.owner?
            #redirect_to :controller=>"profile_images", :profile => @profile, :new=>"true"
            seller_property = @profile.seller_property_profile
            if !seller_property.blank? and !seller_property.seller_profile.blank?
                 redirect_to :controller => :seller_websites, :action => :property, :id => seller_property.seller_profile.id
            else
              redirect_to profile_profile_images_path(@profile, :new=>"true")
            end        
          else
            flash[:notice] = "Buyer Lead Successfully created"
            redirect_to :controller=>"account", :action=>"add_buyer_created"
          end
          return
        else
          # 6. Take the user to a "pending email" page, with a confirmation textbox entry
          flash[:user] = @user
          flash[:profile] = @profile
          @target_url = buyer_created_new_user_url if @profile_type.buyer?
          @target_url = owner_created_new_user_url if @profile_type.owner?
          @target_url = buyer_agent_created_new_user_url if @profile_type.buyer_agent?
          @target_url = seller_agent_created_new_user_url if @profile_type.seller_agent?
          redirect_to @target_url and return
        end
      end
    end
    @country = params[:fields][:country]
    @state = params[:fields][:state]

    if (@fields.investment_type_id == "1" || @fields.investment_type_id == 3)
      @owner_finance_flag = true
    end

    if(@fields.investment_type_id == "2" || @fields.investment_type_id == 3)
      @wholesale_flag = true
    end
   
    render :action => "new_"+@profile_type.permalink_to_page
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml
  def update
    # 1. Capture fields from the request into a form object
    @fields = ProfileFieldForm.create_form_for(@profile_type.permalink)
    @fields.from_profile_fields(@profile.profile_fields)
    @fields.from_hash(params['fields'])
    @fields.force_submit = true
    @investmant_type_flag, @state_flag, @county_flag, @city_flag, @zipcode_flag, @country_flag = params[:investmant_type_flag], params[:state_flag], params[:county_flag], params[:city_flag], params[:zipcode_flag], params[:country_flag] 
    # skip this in the update process for owners
    # TODO: capture previous property address, compare to the one supplied, and if different then allow validation (loophole exists right now)
    @fields.skip_address_validation! if (@profile_type.owner? or @profile_type.seller_agent?) && (@profile.get_profile_field(:property_address).value == @fields.property_address)
    if(params[:fields][:quick_update] != 'qu')
     if (params[:wholesale].blank? and params[:owner_finance].blank?)
        @uncheck_flag = true
        render :action => "edit_"+@profile_type.permalink_to_page and return
      end
    end
    validated_wholesale_owner_finance_values
    # 2. Validate general fields and fields based on the property type
    if @fields.valid? && @fields.valid_for_property_type?
      # 3. merge the fields, changing only what has been changed, creating new ones as needed - nothing is ever deleted, only nullified
      @fields.merge_profile_fields(@profile)
      @profile.investment_type_id = @fields.investment_type_id if(params[:fields][:quick_update] != 'qu')
      @profile.investment_type_id = @investmant_type_flag unless @investmant_type_flag.blank?
      update_profile_display_option
      # 4. Save updated profile fields
      begin
        @profile.profile_fields.each { |field| field.save! }
        # trigger the observer by forcing an update on the profile as well
        @profile.country = params['fields']['country'] unless params['fields']['country'].blank?
        @profile.before_save
        unless @investmant_type_flag.blank?
          @zip_code = @zipcode_flag
          update_buyering_area_and_related_value(@country_flag, @state_flag, @city_flag, @county_flag) 
        end
        if @profile.save!
          @profile.update_seller_property_profile unless @profile.seller_property_profile.blank?
        end
        log_activity(:activity_category_id=>'cat_prof_updated', :user_id=>current_user.id, :profile_id=>@profile.id, :session_id=>request.session_options[:id])
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error saving your profile updates",exp) and return
      end

      # 5. Take them back to their dashboard
      redirect_to profile_path(@profile) and return
    end
    if (@fields.investment_type_id == "1" or @fields.investment_type_id == 3)
          @owner_finance_flag = true
      end
      if(@fields.investment_type_id == "2" or @fields.investment_type_id == 3)
        @wholesale_flag = true
      end
    # redraw the edit form and render any errors
    @country = params[:fields][:country]
    @state = params[:fields][:state]
    render :action => "edit_"+@profile_type.permalink_to_page
  end

  # PUT /profiles/1;update_zipcodes
  def update_zipcodes
    @profile = Profile.find(params[:id])
    @profile_type = ProfileType.find_by_name("buyer")
    @zip_code = params[:zip_code]
    @fields = ProfileFieldForm.create_form_for(@profile_type.permalink)
    @fields.from_profile_fields(@profile.profile_fields)
    # save change
    @city_flag =  params[:city].blank? ? nil : params[:city][:city]
    @state_flag = params[:state].blank? ? nil : params[:state]
    @country_flag = params[:country].blank? ? nil : params[:country]
    if params[:wholesale].blank? and !params[:owner_finance].blank?
      @counties = nil
    else
      @counties =  params[:county].blank? ? nil : params[:county][:county]
    end
    county_string = String.new
    unless @counties.blank?
      @counties.each do |county|
        county_string = county and next if county_string.blank?
        county_string = county_string.to_s+","+county.to_s
      end 
    else
      county_string = nil
    end
    update_invesment_type
    @profile.investment_type_id = @fields.investment_type_id
    if @profile.investment_type_id_changed? and (!@fields.valid? or !@fields.valid_for_property_type?)
      @county_flag = county_string
      @investmant_type_flag = @fields.investment_type_id
      @zipcode_flag = @zip_code
      @owner_finance_flag = true if (@fields.investment_type_id == "1" or @fields.investment_type_id == 3)
      @wholesale_flag = true if(@fields.investment_type_id == "2" or @fields.investment_type_id == 3)
      @fields.arv_repairs_value = "70" if @wholesale_flag and @fields.arv_repairs_value.blank?
      render :action => "edit_"+@profile_type.permalink_to_page
    else
      @fields.force_submit = true
      update_buyering_area_and_related_value(@country_flag, @state_flag, @city_flag, county_string)
      update_profile_display_option
      # trigger observer
      @profile.save!
      unless @zip_code.blank?
        if @profile.owner?
          @zip_code = @zip_code.split(/[^0-9]+/).first
        end
        click_route = url_for :controller => 'profiles', :action => @profile.owner? ? 'single_zip_select' : 'multi_zip_select'
        @map = ZipCodeMap.prepare_map(@zip_code, :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
        @boundary_overlays = ZipCodeMap.prepare_boundary_overlays(@zip_code)
        @js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value") unless @profile.owner?
      end
      respond_to do |format|
        if @profile.update_attributes(params[:profile])
          flash[:notice] = 'Profile was successfully updated.'
          # format.html { redirect_to profile_url(@profile) }
          format.html { redirect_to profile_path(@profile) and return }
          format.xml  { head :ok }
        else
          format.html redirect_to(:action => "edit_zipcodes")
          format.xml  { render :xml => @profile.errors.to_xml }
        end
      end
    end
  end

  

  # DELETE /profiles/1
  # DELETE /profiles/1.xml
  def destroy
    @profile_form = Profile.new(params[:profile_form])

    # revert back if user don't select delete reason 
    if @profile_form.profile_delete_reason_id.blank?
      @profile_delete_reasons = ProfileDeleteReason.find_for_profile(@profile)
      @profile_form.errors.add("profile_delete_reason_id", "Please select a reason")
      render :action=>"delete_confirm", :id => @profile.id and return
    end
    begin
      # profile should not be archived if user select delete reason as 'other'
      @profile.soft_delete(@profile_form)
      Profile.transaction do 
        SyndicateProperty.save_manual_syndicate_property(@profile.id, current_user, false) if @profile.profile_type_id == 'ce5c2320-4131-11dc-b432-009096fa4c28'
        if @profile_form.profile_delete_reason_id == "other"
          @profile.profile_delete_reason_id = @profile_form.profile_delete_reason_id
          @profile.delete_without_archiving
        else
          @profile.soft_delete(@profile_form)
        end
      end
      
      flash[:notice] = "Your profile has been deleted"
    rescue  Exception => exp
      @profile.skip_permalink_before_save = false
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      handle_error("Error deleting your profile",exp) and return
    end
    @profile.skip_permalink_before_save = false
    redirect_to :controller => "account", :action => "profiles"
  end

  def delete_deal
    Profile.connection.execute("update profiles set deleted_at = NULL where id='#{params[:id]}' and user_id = '#{current_user.id}'")
    @profile = Profile.find(:first,:conditions => ["id = ?",params[:id]])
    if !@profile.blank? and @profile.user_id == current_user.id
      @profile.delete_without_archiving
      @profile.skip_permalink_before_save = false
      delete_deal_badge
      flash[:notice] = "Your Deal has been deleted from your account"
    else
      handle_error "Sorry, but the profile you requested isn't owned by you. Please sign-in as the proper owner to manage this profile" and return
    end
    redirect_to :controller => "account", :action => "show_deals"
  end

  #
  # Marks a profile as spam by anyone in the system, even from a guest visitor from the preview page
  #
  def mark_as_spam_for_profile
    @profile = Profile.find(params[:id])
    spam_claim = SpamClaim.new({ :claim_type=>'Profile', :claim_id=>@profile.id, :created_by_user_id=>current_user.id})
    begin
      spam_claim.save!
      spam_claim.connection.update("UPDATE profiles SET marked_as_spam = true WHERE id = '#{@profile.id}'")
      
       #sending email through Resque
      Resque.enqueue(ProfileMarkedAsSpamNotificationWorker,spam_claim.id, @profile.id)
      render :update do |page|
        # add the new tag to the top of the table
        page.replace_html "marked_as_spam", "Flagged"
        # highlight the new text
        page.visual_effect :highlight, "marked_as_spam"
      end if request.xhr?

    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      handle_error("Internal error - could not mark as spam",exp) and return
    end
  end

  def give_spam_reason
    @profile_message = ProfileMessage.find(params[:id])
    the_dom_id = params[:dom].gsub('-','_') if params[:dom]
    spam_claim = SpamClaim.new({ :claim_type=>'ProfileMessage', :claim_id=>@profile_message.id, :created_by_user_id=>current_user.id})
    begin
      spam_claim.save!
      spam_claim.connection.update("UPDATE profile_messages SET marked_as_spam = true, spam_reason = '#{params[:profile_message][:spam_reason]}' WHERE id = '#{@profile_message.id}'")

      #sending email through Resque
      Resque.enqueue(ProfileMessageMarkedAsSpamNotificationWorker,spam_claim.id, @profile_message.id)

      render :text=>"Marked as spam"

    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification( e, self, request, params)
      handle_error("Internal error - could not mark as spam",e) and return
    end
  end

  def mark_as_spam_for_profile_inbox
     render :layout=>false
  end

  def profile_contact
  end

  def update_profile_contact
    @is_profile_contact, @is_profile_contact_phone = true, true
    @profile_contact_name = params[:profile][:contact_name]
    @profile_contact_phone = params[:profile][:contact_phone]
    @profile.is_primary_contact_for_property_profile = true
    if @profile.update_attributes(params[:profile])
      flash[:notice] = "Primary contact updated successfully"
      redirect_to profile_contact_profile_path(@profile)
    else
      render :action => "profile_contact"
    end
  end
  # XHR
  def edit_private_display_name
    # separate model for the edit form
    @target_profile = Profile.find_by_id(@profile.id)
    render :layout=>false
  end

  # XHR
  def update_private_display_name
    # separate model for the edit form
    @target_profile = Profile.find_by_id(@profile.id)

    if params[:target_profile].nil? or params[:target_profile][:private_display_name].nil? or params[:target_profile][:private_display_name].empty?
      @target_profile.errors.add("private_display_name", "is required")
      render :action=>"edit_private_display_name", :layout=>false and return
    end

    begin
      @target_profile.update_attributes({ :private_display_name => params[:target_profile][:private_display_name], :is_profile_display_name_updated_by_user => true })

      # use RJS to update the div, close lightbox, and highlight changed name
      render :update do |page|
        # close the lightbox
        page.call "lightbox_controller.close"

        # update the dashboard to use the new name
        page.replace_html 'private_display_name', link_to_remote(truncate(@target_profile.private_display_name,:length => 25),{
            :url => {
              :action => 'edit_private_display_name'
            },
            :method => :get,
            :update         => "lightbox_contents",
            :loading        => "lightbox_controller.loading()",
            :loaded         => "lightbox_controller.loaded()"},{
            :title=>"Rename Buyer Profile"})

        # hightlight the change
        page.visual_effect :highlight, 'private_display_name', :duration => 1.5
      end

      # redirect to the dashboard after the rename
      #redirect_to profile_path(@target_profile.id)
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      handle_error("Internal error - could not update the private display name\n#{exp.backtrace.join("\n\r")}",exp) and return
    end
  end  
  
  # To select multiple areas on the map
  def select_multiple_areas_on_map    
    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select'
    ziplist = []    
        
      zips = Zip.find(:all, :conditions => ["state LIKE ? and city LIKE ? and direction LIKE '%#{params[:direction]}%'", params[:state], params[:city]], :select => "zip")
#      zips = Zip.find(:all, :conditions => ["state LIKE ? and direction LIKE '%#{params[:direction]}%'", params[:state]], :select => "zip")
      zips.each do |zip|
        ziplist << zip.zip
      end
      ziplist = ziplist.join(',')      
      
      if !params[:zipcodes].blank? and !params[:zipcodes].include? ziplist 
        ziplist += "," + params[:zipcodes].to_s       
#        ziplist = ziplist.split(',').uniq.join(',')        
      else
        if !params[:zipcodes].blank?
          params[:zipcodes].slice!(ziplist)
          params[:zipcodes] = params[:zipcodes].split(',')
          params[:zipcodes].delete("")
#          params[:zipcodes] = params[:zipcodes].uniq if params[:zipcodes]
          ziplist = params[:zipcodes].join(',')
        end
      end

    lat = Zip.find(:first, :conditions => ["state LIKE ? and city LIKE ? and direction LIKE '%#{params[:direction]}%'", params[:state], params[:city]], :select => "lat", :order => "lat")
    lng = Zip.find(:first, :conditions => ["state LIKE ? and city LIKE ? and direction LIKE '%#{params[:direction]}%'", params[:state], params[:city]], :select => "lng", :order => "lng desc")
    
    boundary_overlays = ZipCodeMap.prepare_boundary_overlays(ziplist)
    js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value")

    render :update do |page|      
      page << "$('zip_code').value = '" + ziplist + "'";
      page << "map.clearOverlays();"
      page << "map.setCenter(new GLatLng(#{lat.lat}, #{lng.lng}), 10);" unless lat.nil? && lng.nil?

      boundary_overlays.each do |overlay|        
        page << "map.addOverlay( overlay =" + overlay.to_javascript() + ")"
        page << "GEvent.addListener( overlay, 'click', " + js + ")"
      end
    end
  end

  def edit_notification
    @profile_field = ProfileFieldEngineIndex.profile_id(@profile.id)
    @email = @profile.field_value(:notification_email)
    @phone = @profile.field_value(:notification_phone)
    @first_name = @profile.field_value(:first_name)
    @last_name = @profile.field_value(:last_name)
  end
  
  def update_notification    
   begin
    @parameters = params
    @profile = Profile.find(params[:id])
    @retail_buyer = RetailBuyerProfile.find_by_profile_id(params[:id])
    if (params[:first_name].blank?)
            flash[:error] = "first name can't be blank"
            redirect_to  edit_notification_profile_path(@parameters) and return
    end
    if (params[:last_name].blank?)
            flash[:error] = "last name can't be blank"
            redirect_to  edit_notification_profile_path(@parameters) and return
    end


    if !@retail_buyer.nil?
       @retail_buyer.update_attributes(:first_name => params[:first_name], :last_name => params[:last_name], :email_address => params[:profile_field_engine_index][:notification_email], :phone => params[:profile_field_engine_index][:notification_phone]  )
    end
    @profile.profile_fields.each do |pf|
     if( pf.key == 'first_name' ) then
        pf.value = params[:first_name]
        @pf_flag_fn = true
        pf.save!
     end
    end
    @profile.profile_fields.each do |pf|
     if( pf.key == 'last_name' ) then
        pf.value = params[:last_name]
        @pf_flag_ln = true
        pf.save!
     end
    end
    @profile.profile_fields.each do |pf|
     if( pf.key == 'notification_email' ) then
        pf.value = params[:notification_email]
        pfvalue_downc =  pf.value.downcase
        if (!params[:notification_email].blank?)
          unless ((3..100) === pf.value.length && pfvalue_downc.match('^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$'))
            flash[:error] = "email format invalid"
            redirect_to  edit_notification_profile_path(@parameters) and return
          end
        end
        @pf_flag_email = true
        pf.save!
     end
    end
    @profile.profile_fields.each do |pf|
      if( pf.key.eql? 'notification_active' ) then
        pf.value = params[:profile_field_engine_index][:notification_active]
        pf.save!
        break
      end
    end
    @profile.profile_fields.each do |pf|
      if( pf.key == 'notification_phone' ) then
        pf.value = params[:notification_phone]
        @pf_flag_ph = true
        pf.save!
        break
      end
    end
      if !@pf_flag_ph
        @profile.profile_fields.create(:key=>'notification_phone',:value=>"#{params[:notification_phone]}")
      end
      if !@pf_flag_fn
        @profile.profile_fields.create(:key=>'first_name',:value=>"#{params[:first_name]}")
      end
      if !@pf_flag_ln
        @profile.profile_fields.create(:key=>'last_name',:value=>"#{params[:last_name]}")
      end

      if !@pf_flag_email
      @profile.profile_fields.create(:key=>'notification_email',:value=>"#{params[:notification_email]}")
      end
    @profile.profile_nickname = params[:first_name]
    profile_price_value = @profile.is_owner_finance_profile? ? @profile.field_value(:max_dow_pay) : @profile.field_value(:max_purchase_value)
    @profile.private_display_name = sprintf "%s, %s, %s", @profile.profile_nickname, @profile.investment_type.name, profile_price_value

    @profile.save!
    flash[:notice] = "Notification details updated successfully."
    redirect_to profile_path and return
   rescue
    redirect_to profile_path and return
   end
  end
  
  def import   
    if request.post?  
      if params[:uploaded_data].blank?
        flash[:error] = "Please upload a txt/csv file"
        redirect_to :action => "import" and return
      else
        file_name =  params[:uploaded_data][:datafile].original_filename
        flash[:messages] = []
        if[".csv",".txt"].include?(File.extname(file_name))          
          post = Profile.upload_buyer_profiles(params[:uploaded_data])
          no_of_records = 0;
          csv_file_path = "public/data/#{file_name}"
          FasterCSV.foreach(csv_file_path, :headers => true, :header_converters => :symbol, :col_sep => '|', :quote_char => "|")  { |line| no_of_records = no_of_records + 1 }
          if(no_of_records > 50)
            flash[:error] = "CSV file should have a maximum of 50 records only"
            redirect_to :action => "import" and return
          else
            flash[:messages] << "Uploading File.....DONE"       
            create_buyers(file_name)          
          end
          File.delete("public/data/#{file_name}")
        else
          flash[:error] = "Invalid file type"
          redirect_to :action => "import" and return
        end
      end
      redirect_to :controller => 'account', :action => 'profiles' and return
    end
  end
  
  def create_buyers(file)
    csv_file_path = "public/data/#{file}"
    FasterCSV.foreach(csv_file_path, :headers => true,:header_converters => :symbol,:converters => :numeric ) do |line|
      begin
      @fields = ProfileFieldForm.create_form_for("buyer")
      @fields.property_type = 'single_family'
      @fields.zip_code = "76578"
      @fields.beds = line[:beds].to_s
      @fields.baths = line[:baths].to_s
      @fields.square_feet_min = line[:sqft_min].to_s
      @fields.square_feet_max = line[:sqft_max].to_s
      @fields.max_mon_pay = line[:max_monthly_payment].to_s
      @fields.max_dow_pay = line[:max_down_payment].to_s
      @fields.description = line[:comments]      
      @user = current_user    
      
      # 2. Validate general fields and fields based on the property type
      if @fields.valid? && @fields.valid_for_property_type?
        
        # 3. Validate user account
        if logged_in? or @user.valid?
          # 4. Construct a profile and attach fields
          @profile = Profile.new
          @profile.profile_fields = @fields.to_profile_fields
          
          @profile.profile_type = ProfileType.find_by_name('buyer')
          @profile.user = @user
          @profile.generate_name       

          # 5. Save account and profile, generate confirmation email for new account
          begin
            Profile.transaction do
              @user.profiles << @profile
              @profile.save! if current_user
              @profile.update_attribute(:private_display_name, line[:profile_name]) if !line[:profile_name].blank?
              @user.save! unless current_user
              log_activity(:activity_category_id=>'cat_acct_created', :user_id=>@user.id, :session_id=>request.session_options[:id]) unless current_user
              user_id = @user.id unless logged_in?
              user_id = current_user.id if logged_in?
              log_activity(:activity_category_id=>'cat_prof_created', :user_id=>user_id, :profile_id=>@profile.id, :session_id=>request.session_options[:id])
            end
          rescue  Exception => exp
            ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
            handle_error("Error saving your new profile",exp) and return
          end # end of begin         
        end # end of inner if
      end # end of outer if
        flash[:messages] << "Created buyer profile \"#{line[:profile_name]}\""
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        flash[:messages] << "Error occurred while creating profile \"#{line[:profile_name]}\""
      end
    end # end of for each
  end # end of function
  
  def assign_fields(params_fields)
    @temp_hash = {}
    params_fields.each do |k,v| 
      @temp_hash[k.to_sym] = v
    end
    return @temp_hash
  end

  def manual_syndication
    Rails.logger.info "#Method - manual_syndication# ----------- #{params.inspect}"
    @user_subscription = current_user.user_class.user_type_name
    @profile_id = params['id']
    @profile = Profile.find(params['id'])
    @sites_array = ProfileSite.find_all_by_profile_id(params[:id]).map{ |ps| ps.site_id }
    @short_url = @profile.property_synd_url
    syndicator_listing
  end
  
  def save_sites
    Rails.logger.info "#Method - save_sites# ----------- #{params.inspect}"
    ProfileSite.update_site_settings(params[:profile_id], params[:sites]) if !params[:sites].nil?
    SyndicateProperty.save_manual_syndicate_property(params[:profile_id], current_user) if !params[:sites].nil?
    flash[:notice] = "Property queued for  Syndication" 
    flash[:notice] = "Select Sites to Syndicate" if params[:sites].nil?
    redirect_to :back
  end

  def seller_lead_info
    profile =  Profile.find(params[:id])
    profile_seller_mapping = profile.profile_seller_lead_mapping
    if !profile_seller_mapping.blank?
      redirect_to  seller_lead_full_page_view_seller_website_path(:id => profile_seller_mapping.seller_profile_id)
    end
  end

  private


  def delete_deal_badge
    badge = Badge.find(:first,:conditions => ["name = ?",'Deal Maker'])
    unless badge.blank?
      badge_map = BadgeUser.find(:first,:conditions => ["user_id =? and badge_id = ?", current_user.id, badge.id])
      deal_completed = Profile.no_of_deals_completed(current_user.id)
      badge_map.destroy if !badge_map.blank? and !(badge.deals_completed.to_i <= deal_completed.to_i)
    end
  end

  def update_profile_display_option
    unless @profile.is_profile_display_name_updated_by_user
      profile_price_value= @profile.is_owner_finance_profile? ? @fields.max_dow_pay : @fields.max_purchase_value
      if !@profile.profile_nickname.blank?
        @profile.private_display_name = sprintf "%s, %s, %s", @profile.profile_nickname, @profile.investment_type.name, profile_price_value
      elsif @profile.retail_buyer_profile && !@profile.retail_buyer_profile.first_name.blank?
        @profile.profile_nickname = @profile.retail_buyer_profile.first_name
        @profile.private_display_name = sprintf "%s, %s, %s", @profile.retail_buyer_profile.first_name, @profile.investment_type.name, profile_price_value
      else
        @profile.private_display_name = sprintf "%s %s, %s, %s", @profile.display_property_type, @profile.profile_type.name_string, @profile.investment_type.name, profile_price_value
      end
    end
  end

  def update_buyering_area_and_related_value(pro_country, pro_state, pro_city, county_string)
    @profile.profile_fields.each { |field| field.save! }
#     unless county_string.blank? 
#       c_first = county_string.split(",").first
#       c = County.find(:first, :conditions => ["name = ?",c_first])
#       county_zip = Zip.find(:first, :conditions => ["county_id = ?", c.id])
#       @zip_code = county_zip.zip
#     end
    @profile.profile_fields.each do |pf|
      if( pf.key.eql? 'county' ) then
        county_string = nil if county_string.blank?
        pf.value_text = county_string
        pf.value = county_string
        pf.save!
        break
      end
    end
    unless @zip_code.blank?
      @profile.profile_fields.each do |pf|
        if( pf.key.eql? 'zip_code' ) then
          pf.value_text = @zip_code
          pf.value = @zip_code
          pf.save!
          break
        end
      end
    end
    if pro_country == "CA"
      zip_code = Zip.find(:first,:conditions => ["city = ? and country = ? and state = ? ",pro_city, "ca",pro_state])
      zip = (zip_code.blank?) ? nil : zip_code.zip
      @profile.profile_fields.each do |pf|

        if( pf.key.eql? 'zip_code' ) then
          pf.value_text = zip
          pf.save!
          break
        end
      end
    end
    @profile.country = pro_country
    @profile.state = pro_state
    @profile.city = pro_city
  end

  
  def create_seller_engagement_infos_for_publish_seller_property
    seller_property = @profile.seller_property_profile
    engagement_note = seller_property.seller_engagement_infos.create(:description => "Property posted to Marketplace", :note_type => "Action" )
  end
  
  def set_profile_field_values (seller_property_profile_id)
     seller_property_profile = SellerPropertyProfile.find_by_id(seller_property_profile_id)
     baths = set_baths(seller_property_profile.baths)
     fields = {:property_type =>seller_property_profile.property_type,
            :privacy =>seller_property_profile.privacy,
            :zip_code =>seller_property_profile.zip_code,
            :type =>nil,
            :property_address =>seller_property_profile.property_address,
            :units =>seller_property_profile.units,
            :units_min =>0,
            :units_max =>0,
            :beds =>seller_property_profile.beds.to_s,
            :baths =>baths.to_s,
            :garage =>seller_property_profile.garage,
            :stories =>seller_property_profile.stories ,
            :square_feet =>seller_property_profile.square_feet,
            :square_feet_min=>0,
            :square_feet_max=>0,
            :neighborhood=>seller_property_profile.neighborhood,
            :condo_community_name =>seller_property_profile.condo_community_name,
            :price =>seller_property_profile.asking_home_price,
            :price_min => nil,
            :price_max => nil,
            :max_mon_pay => nil,
            :max_dow_pay => nil,
            :min_mon_pay =>seller_property_profile.min_mon_pay,
            :min_dow_pay =>seller_property_profile.min_dow_pay,
            :contract_end_date =>(Date.today + 180).to_s(:db),
            :notification_active => 1,
            :notification_email =>seller_property_profile.notification_email ,
            :deal_terms =>seller_property_profile.deal_terms ,
            :video_tour => seller_property_profile.video_tour ,
            :embed_video => seller_property_profile.embed_video ,
            :county =>seller_property_profile.county ,
            :acres =>seller_property_profile.acres,
            :acres_min =>0,
            :acres_max =>0,
            :description  =>seller_property_profile.description  ,
            :feature_tags =>seller_property_profile.feature_tags,
            :trees => seller_property_profile.feature_tags,
            :waterfront => seller_property_profile.waterfront,
            :pool => seller_property_profile.pool,
            :livingrooms =>seller_property_profile.livingrooms ,
            :formal_dining =>seller_property_profile.formal_dining ,
            :breakfast_area =>seller_property_profile.breakfast_area,
            :school_elementary =>seller_property_profile.school_elementary,
            :school_middle =>seller_property_profile.school_middle ,
            :school_high =>seller_property_profile.school_high,
            :total_actual_rent =>seller_property_profile.total_actual_rent,
            :water =>seller_property_profile.water,
            :sewer =>seller_property_profile.sewer,
            :electricity =>seller_property_profile.electricity,
            :natural_gas =>seller_property_profile.natural_gas ,
            :house =>seller_property_profile.house,
            :manufactured_home =>seller_property_profile.manufactured_home ,
            :barn =>seller_property_profile.barn,
            :fencing =>seller_property_profile.fencing,
            :notification_phone =>seller_property_profile.notification_phone
	    }
            @country = seller_property_profile.country
            @state = seller_property_profile.state
            @fields.from_hash(fields)
      	 end
	 
	 def set_baths(baths)
	    if !baths.blank?
		case
		  when baths == 1 then return "1"
		  when baths == 1.5 then return "2"
		  when baths == 2 then return "3"
		  when baths == 2.5 then return "4"
		  when baths == 3 then return "5"
		  when baths == 4 then return "7"
		  when baths == 5 then return "9"
		  when baths == 6 then return "11"
		end
	    else
		return nil
	    end
       end


  def validated_wholesale_owner_finance_values

   if(params[:fields][:quick_update] == 'qu')
     if @fields.investment_type_id == "3"
        @owner_finance_flag = true
        @wholesale_flag = true
        validate_wholesale_owner_finance
      elsif @fields.investment_type_id == "2"
        @wholesale_flag = true
        validate_wholesale
      elsif @fields.investment_type_id == "1"
         @owner_finance_flag = true
         validate_owner_finance
      end
   elsif !params[:wholesale].nil? and !params[:owner_finance].nil?
      @fields.investment_type_id = 3
      validate_wholesale_owner_finance
     elsif !params[:wholesale].nil?
      @fields.investment_type_id = params[:wholesale]
      @fields.max_mon_pay = nil
      @fields.max_dow_pay = nil
      validate_wholesale
      elsif !params[:owner_finance].nil?
        @fields.investment_type_id = params[:owner_finance]
        @fields.max_purchase_value = nil
        @fields.arv_repairs_value = nil
        validate_owner_finance
     end
  end

  def update_invesment_type
    if !params[:wholesale].nil? and !params[:owner_finance].nil?
      @fields.investment_type_id = 3
      validate_wholesale_owner_finance
    elsif !params[:wholesale].nil?
      @fields.investment_type_id = params[:wholesale]
      validate_wholesale
      @profile.profile_fields.each do |pf|
        if( pf.key.eql? 'max_mon_pay' ) then
          pf.value_text = nil
          pf.value = nil
          pf.save!
        end
        if( pf.key.eql? 'max_dow_pay' ) then
          pf.value_text = nil
          pf.value = nil
          pf.save!
        end
     end
    elsif !params[:owner_finance].nil?
      @fields.investment_type_id = params[:owner_finance]
      validate_owner_finance
      @profile.profile_fields.each do |pf|
        if( pf.key.eql? 'max_purchase_value' ) then
          pf.value_text = nil
          pf.value = nil
          pf.save!
        end
        if( pf.key.eql? 'arv_repairs_value' ) then
          pf.value_text = nil
          pf.value = nil
          pf.save!
        end
      end
    end
  end

  def validate_wholesale
    if @profile_type.owner? || @profile_type.seller_agent?
      @fields.wholesale_owner = true
    end
    if @profile_type.buyer? || @profile_type.buyer_agent?
      @fields.wholesale_buyer = true
    end
  end
  def validate_owner_finance
    if @profile_type.owner? || @profile_type.seller_agent?
      @fields.finance_owner = true
    end
    if @profile_type.buyer? || @profile_type.buyer_agent?
     @fields.finance_buyer = true
    end
  end
  def validate_wholesale_owner_finance
    if @profile_type.owner? || @profile_type.seller_agent?
      @fields.wholesale_owner = true
      @fields.finance_owner = true
    end
    if @profile_type.buyer? || @profile_type.buyer_agent?
      @fields.wholesale_buyer = true
      @fields.finance_buyer = true
    end
  end

end
