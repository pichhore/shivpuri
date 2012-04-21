class InvestorBuyerWebPageController < ApplicationController
  layout "investor_web_page"
 
  before_filter :check_buyer_permalink, :only => [:investor_buyer_web_page_latest, :property_full_view_latest, :property_view_latest, :terms_of_use_latest, :new_retail_buyer_zipselect_latest, :new_retail_buyer_latest, :sequeeze_page]

  before_filter :check_territory_and_business_name, :only =>[:new_retail_buyer_zipselect,:new_retail_buyer,:create_retail_buyer, :thank_you_page,:update_match_criteria, :contact_us, :investor_request_information, :select_zip_code, :terms_of_use, :select_zip_code_latest]
  
  PROPERTIES_PER_PAGE = "5"

  #### Added new set of buyer website methods to support latest format websites(with domains), while the existing sites(in old format) will use the existing methods. All the duplicate methods will be removed from this controller once all the existing buyer websites converted to the new format.

  

  def property_full_view
    unless params[:full_page_view] == "full_property_view"
      render :file => "#{RAILS_ROOT}/public/404.html"
      return false
    end
    @territory_param_name = request.path.gsub(params[:permalink],"").gsub(params[:type],"").gsub(params[:property_id],"").gsub(params[:full_page_view],"").gsub("/","")
    get_user_by_territory(params[:permalink])
    if @buyer_web_page.nil? || @buyer_web_page.active  == false
      render :file => "#{RAILS_ROOT}/public/404.html"
      return
    end
    @current_user = @buyer_web_page.user_territory.user
    @page_title="REIMatcher : Property Full View"
    @buyer_user_image = BuyerUserImage.find_buyer_profile_image(@buyer_web_page.user_territory.user.id)
    @profile = Profile.find_by_id(params[:property_id].to_s)
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @profile.blank?
    if @profile.public_profile?
      # center map on address
      # LATLNG
      center_latlng = @profile.owner? ? @profile.latlng : nil
      # center_latlng = @target_profile.owner? ? ZipCodeMap.lookup_latlng(@target_profile.geocoder_address) : nil
      if center_latlng == nil then
        @map = ZipCodeMap.prepare_map(@profile.zip_code, :suppress_controls => true, :zoom_level => 11, :map_type_init => GMapType::G_HYBRID_MAP )
      else
        @map = ZipCodeMap.prepare_map(@profile.zip_code, :suppress_controls => true, :zoom_level => 17, :center_latlng => center_latlng, :map_type_init => GMapType::G_HYBRID_MAP )
        @marker_overlays = ZipCodeMap.prepare_marker_overlays([@profile], :context_profile=>@profile)
      end
    else
      @map = nil
    end
    method_for_request_information if request.post?
    render :layout=>false, :action=>:property_view
  end
  
  def property_view
    @territory_param_name = request.path.gsub(params[:type],"").gsub(params[:business_name],"").gsub("/","")
    @territory_param_name = @territory_param_name.gsub(params[:address],"") unless params[:address].blank?
    if params[:type].include?("sp") && params[:type].delete("sp").to_i > 0
      get_user_by_squeeze_territory(params[:business_name], params[:type])
      if @buyer_web_page.nil? || @buyer_web_page.active  == false
        render :file => "#{RAILS_ROOT}/public/404.html"
        return        
      elsif !@buyer_web_page.domain_permalink_text.blank?
        @squeeze_type = true 
        render :template => "/investor_buyer_web_page/site_changed", :layout => false
        return
      end
      if request.post? and params[:commit] == ""
        @squeeze_page_opt_in = SqueezePageOptIn.new(params[:squeeze_page_opt_in])
        if @squeeze_page_opt_in.valid?
          @squeeze_page_opt_in.user_territory_id = @buyer_web_page.user_territory.id unless @buyer_web_page.user_territory.nil?
          @squeeze_page_opt_in.save
          redirect_to :action=>:new_retail_buyer_zipselect ,:id => params[:business_name], :territory_name=>@territory_param_name,:first_name=>params[:squeeze_page_opt_in][:retail_buyer_first_name], :email=>params[:squeeze_page_opt_in][:retail_buyer_email]
          return
        else
          render :action=>:squeeze_page ,:layout=>false
          return
        end
      else
        @squeeze_page_opt_in = SqueezePageOptIn.new
        render :action=>:squeeze_page ,:layout=>false
        return
      end
    end
    @uses_yui_lightbox = true
    property_type = params[:type]
    property_address = params[:address]
    @profiles = ProfileFieldEngineIndex.find(:all,:conditions=>["property_type = ? and profiles.permalink = ? ",property_type, property_address],:include=>[:profile])
    @profiles.each{ |profile_obj| @profile = profile_obj.profile if ( !profile_obj.profile.nil? ) && ( profile_obj.profile.permalink == params[:address]) }
    unless @profile.nil?
      get_user_by_territory(params[:business_name] ) unless params[:business_name].blank?
      if @buyer_web_page.nil? || @buyer_web_page.active  == false
        render :file => "#{RAILS_ROOT}/public/404.html"
        return
      end
      @current_user = @buyer_web_page.user_territory.user
      @buyer_user_image = BuyerUserImage.find_buyer_profile_image(@current_user.id)
      if @profile.public_profile?
        center_latlng = @profile.owner? ? @profile.latlng : nil
        if center_latlng == nil then
          @map = ZipCodeMap.prepare_map(@profile.zip_code, :suppress_controls => true, :zoom_level => 11, :map_type_init => GMapType::G_HYBRID_MAP )
        else
          @map = ZipCodeMap.prepare_map(@profile.zip_code, :suppress_controls => true, :zoom_level => 17, :center_latlng => center_latlng, :map_type_init => GMapType::G_HYBRID_MAP )
          @marker_overlays = ZipCodeMap.prepare_marker_overlays([@profile], :context_profile=>@profile)
        end
      else
        @map = nil
      end
    end
    method_for_request_information if request.post?
    if @buyer_web_page.nil? || @buyer_web_page.active  == false
      render :file => "#{RAILS_ROOT}/public/404.html"
      return
    end
    render :layout => false
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end

  def investor_buyer_web_page
    if params[:id].nil?
       render :file => "#{RAILS_ROOT}/public/404.html"
       return false
    end

    @territory_param_name = request.path.gsub(params[:id],"").gsub("/","")
    #=============Working on Lead magnet=============  
      if params[:squeeze_page_no].blank?
        @squeeze_page_opt_in = SqueezePageOptIn.new
      end
    
    #=============================
    @uses_yui_lightbox = true
    
    #get_gmap_setting(params[:zip_code])
    @map = GMap.new("preview_results_map_div")
    get_user_by_territory(params[:id])
    if @buyer_web_page.nil? || @buyer_web_page.active  == false
      render :file => "#{RAILS_ROOT}/public/404.html"
      return
    elsif !@buyer_web_page.domain_permalink_text.blank?
      render :template => "/investor_buyer_web_page/site_changed", :layout => false
      return
    end
    @zip_code_array = Zip.get_zips_for_territory(@buyer_web_page.user_territory.territory.id)
    @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
    @page_number = (params[:per_page] || "1").to_i
    @page_number = @page_number > 0 ? @page_number : 1
    @fields = InvestorUpdateMatchCriteria.new
    @fields.from_hash(params['fields']) unless params['fields'].blank?
    if ( request.post? || request.get? || params[:xhr] == "1" )
      # This is update match criteria
       if !params[:fields].blank? && (@fields || params[:xhr] == "1")
         territory_profiles, @total_records = Profile.get_bwp_matched_profiles(params[:fields], @zip_code_array, @page_number)
        if territory_profiles.empty?
          flash.now[:zip_code_notice] = "No property match found with the provided criteria"
        else
          flash.now[:zip_code_notice] = "#{@total_records} property matches found with the provided criteria" if params[:xhr].nil?
        end
        @total_pages = (@total_records / PROPERTIES_PER_PAGE.to_i).to_i + (@total_records % PROPERTIES_PER_PAGE.to_i > 0 ? 1 : 0)
        per_page = @page_number - 1
        @profiles = territory_profiles[per_page.to_i * PROPERTIES_PER_PAGE.to_i,PROPERTIES_PER_PAGE.to_i]
      elsif !params[:squeeze_page_opt_in].blank?
        @squeeze_page_opt_in = SqueezePageOptIn.new(params[:squeeze_page_opt_in])
        if @squeeze_page_opt_in.valid?
          @squeeze_page_opt_in.user_territory_id = @buyer_web_page.user_territory.id
          @squeeze_page_opt_in.save
          redirect_to :action=>:new_retail_buyer_zipselect ,:id=>params[:id],:territory_name=>@territory_param_name,:first_name=>params[:squeeze_page_opt_in][:retail_buyer_first_name], :email=>params[:squeeze_page_opt_in][:retail_buyer_email]
          return
        else
          # default_investor_buyer_web_page_search()
        end
      else
        # default_investor_buyer_web_page_search()
      end
    else 
      # default_investor_buyer_web_page_search()
    end
    @xhr = ( (request.post? && !params[:fields].blank? && @fields) || (params[:xhr] == "1") ) ? 1 : 0
    if !params[:fields].nil? && !params[:fields][:zip_code].blank? && request.get? && params[:xhr].nil?
      zip_array = params[:fields][:zip_code].split(',')
      i = 0
      zip_array = zip_array.collect{|zc| 
        if (i!=0 && (i==1 || i %12 == 0))
          i = i+1
          zc+"<br/>"
        else
          i = i+1
          zc
        end}.join(",") 
      flash.now[:zip_code_notice] = " Following zip code selected: #{zip_array}"
    end
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end
  
  def property_full_view_latest
    if params[:full_page_view] != "full_property_view_latest"
      render :file => "#{RAILS_ROOT}/public/404.html"
      return false
    end    
    @current_user = @buyer_web_page.user_territory.user
    @page_title = "REIMatcher : Property Full View"
    @buyer_user_image = BuyerUserImage.find_buyer_profile_image(@buyer_web_page.user_territory.user.id)
    @profile = Profile.find_by_id(params[:property_id].to_s)
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @profile.blank?

    @map = GMap.new("preview_results_map_div")
    if @profile.public_profile?
      center_latlng = @profile.owner? ? @profile.latlng : nil
      if center_latlng.nil?
        @map_params = ZipCodeMap.prepare_map_params(@profile.zip_code, :zoom_level => 11)
      else
        @map_params = ZipCodeMap.prepare_map_params(@profile.zip_code, :zoom_level => 17, :center_latlng => center_latlng)
      end
    else
      @map = nil
    end
    
    method_for_request_information if request.post?
    render :layout=>false, :action => :property_view_latest
  end
  
  def property_view_latest
    if params[:type] == "2" || params[:squeeze_page_opt_in]
      if request.post? and params[:commit] == ""
        @squeeze_page_opt_in = SqueezePageOptIn.new(params[:squeeze_page_opt_in])
        if @squeeze_page_opt_in.valid?
          @squeeze_page_opt_in.user_territory_id = @buyer_web_page.user_territory.id
          @squeeze_page_opt_in.save
          redirect_to :action => :new_retail_buyer_zipselect_latest, :permalink_text => @buyer_web_page.domain_permalink_text, :first_name => params[:squeeze_page_opt_in][:retail_buyer_first_name], :email => params[:squeeze_page_opt_in][:retail_buyer_email]
          return
        else
          if params["preview"]
            render :partial => 'account/buyer_squeeze_webpage_preview', :layout => false
          else
            render :action => :squeeze_page, :layout => false
          end
          return
        end
      else
        @squeeze_page_opt_in = SqueezePageOptIn.new
        if params["preview"]
          render :partial => 'account/buyer_squeeze_webpage_preview', :layout => false
        else
          render :action => :squeeze_page, :layout => false
        end
        return
      end
    end

    @uses_yui_lightbox = true
    property_type = params[:type]
    property_address = params[:address]
    @profiles = ProfileFieldEngineIndex.find(:all,:conditions=>["property_type = ? and profiles.permalink = ? ",property_type, property_address],:include=>[:profile])
    @profiles.each{ |profile_obj| @profile = profile_obj.profile if ( !profile_obj.profile.nil? ) && ( profile_obj.profile.permalink == params[:address]) }

    if @profile
      @current_user = @buyer_web_page.user_territory.user
      @buyer_user_image = BuyerUserImage.find_buyer_profile_image(@current_user.id)
      @map = GMap.new("preview_results_map_div")
      if @profile.public_profile?
        center_latlng = @profile.owner? ? @profile.latlng : nil
        if center_latlng.nil?
          @map_params = ZipCodeMap.prepare_map_params(@profile.zip_code, :zoom_level => 11)
        else
          @map_params = ZipCodeMap.prepare_map_params(@profile.zip_code, :zoom_level => 17, :center_latlng => center_latlng)
        end
      else
        @map = nil
      end
      method_for_request_information if request.post?      
      render :layout => false
    else
      render :file => REI_404_PAGE
      return
    end
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end

  def investor_buyer_web_page_latest
    if params[:squeeze_page_no].blank?
      @squeeze_page_opt_in = SqueezePageOptIn.new
    end
    
    @uses_yui_lightbox = true    
    @map = GMap.new("preview_results_map_div")
    @zip_code_array = Zip.get_zips_for_territory(@buyer_web_page.user_territory.territory.id)
    @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
    @page_number = (params[:per_page] || "1").to_i
    @page_number = @page_number > 0 ? @page_number : 1
    @fields = InvestorUpdateMatchCriteria.new
    @fields.from_hash(params['fields']) unless params['fields'].blank?
    if ( request.post? || params[:xhr] == "1" )
      # This is update match criteria
      if !params[:fields].blank? && (@fields || params[:xhr] == "1")
        territory_profiles, @total_records = Profile.get_bwp_matched_profiles(params[:fields], @zip_code_array, @page_number)
        if territory_profiles.empty?
          flash.now[:zip_code_notice] = "No property match found with the provided criteria"
        else
          flash.now[:zip_code_notice] = "#{@total_records} property matches found with the provided criteria" if params[:xhr].nil?
        end
        @total_pages = (@total_records / PROPERTIES_PER_PAGE.to_i).to_i + (@total_records % PROPERTIES_PER_PAGE.to_i > 0 ? 1 : 0)
        per_page = @page_number - 1
        @profiles = territory_profiles[per_page.to_i * PROPERTIES_PER_PAGE.to_i,PROPERTIES_PER_PAGE.to_i]
      elsif !params[:squeeze_page_opt_in].blank?
        @squeeze_page_opt_in = SqueezePageOptIn.new(params[:squeeze_page_opt_in])
        if @squeeze_page_opt_in.valid?
          @squeeze_page_opt_in.user_territory_id = @buyer_web_page.user_territory.id
          @squeeze_page_opt_in.save
          redirect_to :action => :new_retail_buyer_zipselect_latest , :id => params[:permalink_text],
           :territory_name => @territory_param_name, :first_name => params[:squeeze_page_opt_in][:retail_buyer_first_name], 
           :email => params[:squeeze_page_opt_in][:retail_buyer_email]
          return
        else
          # Re enable this when profiles re added to buyer websites
          # default_investor_buyer_web_page_search()
        end
      else
        # default_investor_buyer_web_page_search()
      end
    else 
      # default_investor_buyer_web_page_search()
    end
    if params[:country] == "ca" and !params[:city].blank?
      zip = Zip.find(:first, :conditions => ["city = ?",params[:city][:city]])
      params[:fields][:zip_code] = zip.zip unless zip.blank?
    end
    @xhr = ( (request.post? && !params[:fields].blank? && @fields) || (params[:xhr] == "1") ) ? 1 : 0
    if !params[:fields].nil? && !params[:fields][:zip_code].blank? && request.get? && params[:xhr].nil?
      zip_array = params[:fields][:zip_code].split(',')
      i = 0
      zip_array = zip_array.collect{|zc| 
        if (i!=0 && (i==1 || i %12 == 0))
          i = i+1
          zc+"<br/>"
        else
          i = i+1
          zc
        end}.join(",") 
      flash.now[:zip_code_notice] = " Following zip code selected: #{zip_array}"
    end
    if params["preview"]
      @territory_reim_name = @user_territory.reim_name
      @business_name = @user_company_info.business_name unless @user_company_info.nil?
      @page_number = (params[:per_page] || "1").to_i
      @page_number = @page_number > 0 ? @page_number : 1
      @zip_code_array = Zip.get_zips_for_territory(@user_territory.territory.id)
      @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
      default_investor_buyer_web_page_search()
      @preview_type = params["preview"]
      render :partial => 'account/buyer_webpage_preview', :layout => 'investor_web_page'
      return
    end
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end
  
  def new_retail_buyer_zipselect
    @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
    get_gmap_setting(params[:field_zip_codes])
  end

  def new_retail_buyer_zipselect_latest
    @country = Territory.find_by_reim_name(@territory_param_name).country unless @territory_param_name.blank?
    @cities = Array.new
    @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
    get_gmap_setting_latest(params[:field_zip_codes])
  end

  def select_zip_code
    @selected_zip_code = params[:field_zip_codes]
    @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
    get_gmap_setting(params[:field_zip_codes])
  end

  def select_zip_code_latest
    @country = Territory.find_by_reim_name(@territory_param_name).country unless @territory_param_name.blank?
    @cities = Array.new
    @selected_zip_code = params[:field_zip_codes]
    @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
    get_gmap_setting_latest(params[:field_zip_codes])
  end

  def new_retail_buyer
    if !params[:zip_code].blank?
      @retail_buyer = RetailBuyerProfile.new
      @retail_buyer.first_name = params[:first_name] unless params[:first_name].blank?
      @retail_buyer.email_address = params[:email_address] unless params[:email_address].blank?
      @fields = ProfileFieldForm.create_form_for("buyer")
      @fields.privacy = "public"
      @fields.zip_code = params[:zip_code]
    else
      if params[:latest]
        redirect_to :action => :new_retail_buyer_zipselect_latest, :territory_name=>@territory_param_name, :id=>@business_name
      else
        redirect_to :action => :new_retail_buyer_zipselect, :territory_name=>@territory_param_name, :id=>@business_name
      end
    end
  end
    
  def new_retail_buyer_latest
    if params[:country] == "ca" or !params[:zip_code].blank?
      @retail_buyer = RetailBuyerProfile.new
      @retail_buyer.first_name = params[:first_name] unless params[:first_name].blank?
      @retail_buyer.email_address = params[:email_address] unless params[:email_address].blank?
      @fields = ProfileFieldForm.create_form_for("buyer")
      @fields.privacy = "public"
#       @fields.zip_code = params[:zip_code]
      @fields.zip_code = params[:zip_code].blank? ? (Zip.find(:first, :conditions => ["city = ? and country = ? and state = ?",params[:city][:city], params[:country], params[:state]]).zip) : params[:zip_code]
       coun = params[:country] == "ca" ? "CA" : "US"
      @fields.country = coun 
      @fields.state = params[:state] unless params[:state].blank?
      @fields.city = params[:city][:city] unless params[:city].blank?
      @latest_retail_buyer = "1"
      render :action => 'new_retail_buyer'
    else
      redirect_to :action => :new_retail_buyer_zipselect_latest, :territory_name=>@territory_param_name, :id=>@business_name
    end
  end

  def create_retail_buyer

    if request.post?
      @retail_buyer = RetailBuyerProfile.new()
      @retail_buyer.from_hash(params['retail_buyer'])
      @profile_type = ProfileType.find_by_permalink("buyer")
      @user = @buyer_web_page.user_territory.user
      @fields = ProfileFieldForm.create_form_for(@profile_type.permalink)
      if !@profile_type.blank? && (@profile_type.permalink == "buyer" || @profile_type.permalink == "buyer_agent")
        params['fields']['contract_end_date'] = (Date.today + 180).to_s(:db) unless params['fields'].blank?
      end
      params['fields']['notification_email'] = @retail_buyer.email_address
      params['fields']['notification_phone'] = @retail_buyer.phone
      params['fields']['notification_active'] = true
      @retail_buyer.alternate_phone = params["retail_buyer"]["alternate_phone"]
      params['fields']['first_name'] = @retail_buyer.first_name
      params['fields']['last_name'] = @retail_buyer.last_name
      params['fields']['notification_mobile']= @retail_buyer.alternate_phone
      if @buyer_web_page.old_format_site?
        zip = Zip.find_by_zip(params['fields']['zip_code'])
        params['fields']['country'] = zip.country
        params['fields']['state'] = zip.state
        params['fields']['city'] = zip.city
      end
      @fields.from_hash(params['fields'])
      @fields.privacy = "public"
      if @fields.valid? && @fields.valid_for_property_type? && @retail_buyer.valid?
        @profile = Profile.new
        @profile.country = @fields.country unless @fields.country.blank?
        @profile.state = @fields.state unless @fields.state.blank?
        @profile.city = @fields.city unless @fields.city.blank?
        @profile.private_display_name = @retail_buyer.first_name
        @profile.url_parameter = @buyer_web_page.user_territory.territory.reim_name
        @profile.permalink_text = @buyer_web_page.permalink_text
        @profile.new_format_url = @buyer_web_page.new_format_url
        @profile.profile_fields = @fields.to_profile_fields
        @profile.profile_type = @profile_type
        @profile.user = @user
        @profile.generate_name
        begin
          Profile.transaction do
            @user.profiles << @profile
            @retail_buyer.profile_id = @profile.id

            @retail_buyer.user_territory_id = @buyer_web_page.user_territory.id
            @retail_buyer.save!
            @profile.profile_nickname = @retail_buyer.first_name
            @profile.private_display_name = sprintf "%s, %s, %s", @retail_buyer.first_name, @profile.investment_type.name, @fields.max_dow_pay
            @profile.save!
            #@buyer_engagement_infos = @retail_buyer.buyer_engagement_infos.create(:subject => notification_email.email_subject, :description => notification_email.email_body, :note_type => "Email" )
            #@buyer_engagement_infos.save!
            investor_url = request.url.gsub(request.path,"")
            url_parameter = @buyer_web_page.user_territory.territory.reim_name
            permalink_text = @buyer_web_page.permalink_text
            
            #sending email through Resque
            Resque.enqueue(BuyerCreatedNotificationWorker, @buyer_web_page.user_territory.user.id, @fields, @retail_buyer.id, investor_url, url_parameter, permalink_text, @buyer_web_page.new_format_url, @profile.city)
            
          end
          rescue Exception => e
          ExceptionNotifier.deliver_exception_notification( e, self, request, params)
          handle_error("Error saving your new profile",e) and return
        end
        redirect_to :action => :thank_you_page, :territory_name => @territory_param_name, :id => @business_name,:email_address => @retail_buyer.email_address, :latest_action => params["latest_action"]
      else
        if params[:latest_action]
          @latest_action = params[:latest_action]
          @latest_retail_buyer = "1"
        end
        render :action => :new_retail_buyer, :layout => true       
      end
    else
      redirect_to :controller=>:home,:action=>:index
    end
  end
  
  def thank_you_page
    @latest_action = params["latest_action"]
    @content_for_web_page_scripts = true
  end

  def check_territory_and_business_name
    @territory_param_name = params[:territory_name] unless params[:territory_name].blank?
    @territory_param_name = request.path.to_s.gsub(params[:id].to_s,"").gsub(params[:action].to_s,"").gsub("/","") if params[:territory_name].blank?
    @business_name = params[:id]
    if params['latest_action'] == "1"
      buyer_web_pages = BuyerWebPage.find(:all,:conditions=>["domain_permalink_text = ?", params[:id]])
    else
      buyer_web_pages = BuyerWebPage.find(:all,:conditions=>["permalink_text = ?", params[:id]])
    end
   
    buyer_web_pages.each do |buyer_web_page|
       @buyer_web_page = buyer_web_page if buyer_web_page.user_territory.territory.reim_name == @territory_param_name
    end

    if @buyer_web_page.nil?
      buyer_web_pages = BuyerWebPage.find(:all,:conditions=>["domain_permalink_text = ?", params[:id]])
      @buyer_web_page = buyer_web_pages[0] if buyer_web_pages.size == 1 || (buyer_web_pages[0] && buyer_web_pages[0].having?)
      unless @buyer_web_page
        host = request.host.match(/www/).nil? ? "www.#{request.host}" : request.host
        @buyer_web_page = buyer_web_pages.select{|x| x.my_website.domain_name == host if x.my_website}.first
      end
    end

    if @buyer_web_page.nil? || @buyer_web_page.active  == false
        render :file => "#{RAILS_ROOT}/public/404.html"
        return
    end

    @user_company_image = @buyer_web_page.user_territory.user.user_company_image
    @user_company_info = @buyer_web_page.user_territory.user.user_company_info
  end

  def contact_us
    if request.post?
      @investor_contact_us = InvestorContactUs.new
      @investor_contact_us.from_hash(params['investor_contact_us'])
      @investor_territory = params['territory_name']
      @investor_id = params['id']
      if @investor_contact_us.valid?
        # sending email through Resque
        Resque.enqueue(InvestorContactNotificationWorker,@buyer_web_page.user_territory.user.id, @investor_contact_us.name,@investor_contact_us.email,@investor_contact_us.phone,@investor_contact_us.message , @investor_territory, @investor_id,@buyer_web_page.new_format_url)
   
        render :partial=>"message_sent", :layout=>false
     else
        render :action=>:contact_us, :layout=>false
     end
    else
      render :layout=>false
    end
  end

  def terms_of_use
  end

  def terms_of_use_latest
    render :action => 'terms_of_use'
  end 
  
  def get_url
    if !params[:id].blank?
      user = User.find(params[:id])
      # use ip address to guess location
      geoip = GeoIP.new( RAILS_ROOT + '/public/geoip/GeoLiteCity.dat' ).city( self.request.remote_ip )
      # For testing
      #geoip = GeoIP.new( RAILS_ROOT + '/public/geoip/GeoLiteCity.dat' ).city("207.97.226.208")
      geoip_zip_code = geoip[ 8 ] unless geoip.nil?
      if geoip_zip_code.blank?
        get_user_first_active_bwp(user,params[:squeeze_page])
      else
        zip = Zip.find(:first, :conditions => ['zip = ? && territory_id is not null', geoip_zip_code])
        unless zip.blank?
          visiting_user_territory = Territory.get_territory_for_zip(zip)
          user_territory_found = user.user_territories.find(:first, :conditions => {:territory_id =>visiting_user_territory.id})
          if user_territory_found
            bwp = BuyerWebPage.find(:first, :conditions => {:user_territory_id => user_territory_found.id, :active => 1})
            if !bwp.blank?
              if params[:squeeze_page].blank?
                redirect_to "/#{visiting_user_territory.reim_name}/#{bwp.permalink_text}"
              else
                redirect_to "/#{visiting_user_territory.reim_name}/#{bwp.permalink_text}/sp#{bwp.user_territory.sequeeze_page_number}"
              end
            else
              get_user_first_active_bwp(user,params[:squeeze_page])
            end
          else
            get_user_first_active_bwp(user,params[:squeeze_page])
          end
        else
          get_user_first_active_bwp(user,params[:squeeze_page])
        end
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html"
    end
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end

  def sequeeze_page
    @squeeze_page_opt_in = SqueezePageOptIn.new
    render :action => :squeeze_page, :layout => false
  end

  def get_user_first_active_bwp(user,squeeze_page)
    user_territory_found = user.user_territories.collect{|ut| ut.id}
    if !user_territory_found.empty?
      bwp = BuyerWebPage.find(:first, :conditions => ["user_territory_id in (?) and active = ?", user_territory_found,  1])
      if !bwp.blank?
        territory = Territory.find((UserTerritory.find(bwp.user_territory_id)).territory_id)
        if squeeze_page.blank?
          redirect_to "/#{territory.reim_name}/#{bwp.permalink_text}"
        else
          redirect_to "/#{territory.reim_name}/#{bwp.permalink_text}/sp#{bwp.user_territory.sequeeze_page_number}"
        end
      else
        render :file => "#{RAILS_ROOT}/public/404.html"
      end
    else
      render :file => "#{RAILS_ROOT}/public/404.html"
    end
  end

  private

  def check_buyer_permalink
    permalink = params[:permalink_text] || params[:id]
    if permalink.blank?
      render :file => REI_404_PAGE
      return
    #else
    #domain_permalink = BuyerWebPage.find_by_domain_permalink_text(permalink)
    
    #if domain_permalink.nil?
      #redirect_to REIMATCHER_URL+"home/preview_owner/#{permalink}"
      #return
    
    #end
    end

    buyer_web_pages = BuyerWebPage.active_buyer_web_page(permalink)
    @buyer_web_page = buyer_web_pages[0] if buyer_web_pages.size == 1 || (buyer_web_pages[0] && buyer_web_pages[0].having?)
    unless @buyer_web_page
      host = request.host.match(/www/).nil? ? "www.#{request.host}" : request.host
      if REIMATCHER_URL.include?(host)
        @buyer_web_page = buyer_web_pages.select{|x| x.my_website.domain_name == params[:domain_name]}.first
      else
        @buyer_web_page = buyer_web_pages.select{|x| x.my_website.domain_name == host if x.my_website}.first
      end
    end

    if @buyer_web_page.nil? && params[:preview]
      @buyer_web_page = BuyerWebPage.first(:conditions => ["domain_permalink_text = ?", permalink])
    end

    if @buyer_web_page 
      set_buyer_site_details
      return true
    else
      render :file => REI_404_PAGE
      return
    end
  end

  def set_buyer_site_details
    @user_territory = @buyer_web_page.user_territory
    @user_company_image = @user_territory.user.user_company_image
    @user_company_info = @user_territory.user.user_company_info
    @territory_param_name = @user_territory.reim_name 
    @business_name = @buyer_web_page.domain_permalink_text
  end

  def get_user_by_territory(business_name)
    @business_name = business_name
    buyer_web_pages = BuyerWebPage.find(:all,:conditions=>["permalink_text = ? ",business_name])
    buyer_web_pages.each do |buyer_web_page|
      @buyer_web_page = buyer_web_page if buyer_web_page.user_territory.territory.reim_name == @territory_param_name
    end

    unless @buyer_web_page.nil?
      @user_company_image = @buyer_web_page.user_territory.user.user_company_image
      @user_company_info = @buyer_web_page.user_territory.user.user_company_info
    end
  end

  def get_user_by_squeeze_territory(business_name, squeeze_name)
    @business_name = business_name
    buyer_web_pages = BuyerWebPage.find(:all,:conditions=>["permalink_text = ? ",business_name])
    buyer_web_pages.each do |buyer_web_page|
      @temp_buyer_web_page = buyer_web_page if buyer_web_page.user_territory.territory.reim_name == @territory_param_name
    end
    unless @temp_buyer_web_page.nil?
      user_territories = @temp_buyer_web_page.user_territory.user.user_territories
      check_sp_of_territory(user_territories, squeeze_name.delete("sp").to_i)
    end
    unless @buyer_web_page.nil?
      @user_company_image = @buyer_web_page.user_territory.user.user_company_image
      @user_company_info = @buyer_web_page.user_territory.user.user_company_info
    end
  end

  def check_sp_of_territory(user_territories, sequeeze_page_number)
    user_territories.each do |ut|
      if ut.territory.reim_name == @territory_param_name and ut.sequeeze_page_number == sequeeze_page_number
        @buyer_web_page = ut.buyer_web_page if ut.buyer_web_page.active
      end
    end
  end

  def get_territory_profile(user_profiles , territory)
    territory_profiles = Array.new
    user_profiles.each do |profile|
      if territory.zips.map(&:zip).include?(profile.display_zip_code)
        territory_profiles.push(profile)
      end
    end
    return territory_profiles
  end

  # Handle numbers with commas
  def formatted_string_to_i(num)
    return 0 if num.nil?
    raw_value = num.delete(",")
    int_value = raw_value.to_i
    max = 2**31-1
    return int_value > max ? max : int_value # columns are defined as int(11) so avoid overflow
  end

  def get_gmap_setting(param_zip_code)
    @zip_code = param_zip_code || ''
    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select'
    @map = ZipCodeMap.prepare_map("78701", :click_route => click_route, :zipcodes_js_source => "$('zip_code').value", :center_latlng => "#{@center_zip_code[0].lat},#{@center_zip_code[0].lng}")
    @boundary_overlays = ZipCodeMap.prepare_boundary_overlays(@zip_code)    

    @js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value")
  end

  def get_gmap_setting_latest(param_zip_code)
    @zip_code = param_zip_code || ''
    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select_latest'
    @map = GMap.new("preview_results_map_div")
    @map_params = ZipCodeMap.prepare_map_params("78701", :click_route => click_route, :zipcodes_js_source => "$('zip_code').value", :center_latlng => "#{@center_zip_code[0].lat},#{@center_zip_code[0].lng}")
  end

  def get_google_map_zip_code(zip_code)
    @map = ZipCodeMap.prepare_map(zip_code)
  end

  def get_google_map_territory(territory_name)
      get_territory  =  Territory.find(:first,:conditions=>["reim_name = ? ",territory_name])
      unless get_territory.nil?
        get_zip  =  Zip.find_by_territory_id(get_territory.id) 
        territory_zip_code = get_zip.zip
        get_google_map_zip_code(territory_zip_code)
      else
         return nil
      end
  end

  def select_google_map_territory(territory_name)
      get_territory  =  Territory.find(:first,:conditions=>["reim_name = ? ",territory_name])
      unless get_territory.nil?
        get_zip  =  Zip.find_by_territory_id(get_territory.id) 
        territory_zip_code = get_zip.zip
        click_route = url_for :controller => 'profiles', :action => 'multi_zip_select'
        @map = ZipCodeMap.prepare_map(territory_zip_code, :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
        @boundary_overlays = Array.new
        @js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value")
      else
         return nil
      end
  end
  
  def default_investor_buyer_web_page_search()
    territory_profiles = Profile.find(:all, :select => "profiles.*, profile_field_engine_indices.zip_code", :joins => ["INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true and  users.activation_code is null "] , :order=>"created_at DESC", :group=>"profile_field_engine_indices.profile_id, profile_field_engine_indices.property_type", :limit => @page_number*5,:conditions=>[" zip_code in ( ? )",@zip_code_array ])
    @total_records = @total_records || Profile.count(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true  and users.activation_code is null",:conditions=>[" zip_code in ( ? )",@zip_code_array ])
    @total_pages = (@total_records / PROPERTIES_PER_PAGE.to_i).to_i + (@total_records % PROPERTIES_PER_PAGE.to_i > 0 ? 1 : 0)
    per_page = @page_number - 1
    @profiles = territory_profiles[per_page.to_i * PROPERTIES_PER_PAGE.to_i,PROPERTIES_PER_PAGE.to_i]
  end

  def method_for_request_information
    @request_information = InvestorRequestInformation.new
    params['request_information']["name"] = "" if params['request_information']["name"] == "Name"
    params['request_information']["phone"] = "" if params['request_information']["phone"] == "Phone"
    params['request_information']["email"] = "" if params['request_information']["email"] == "Email"
    params['request_information']["message"] = "" if params['request_information']["message"] == "Message (optional)"
    @request_information.from_hash(params['request_information'])
    buyer_website_link = params[:buyer_website_link]
    if @request_information.valid?
      # UserNotifier.deliver_notify_investor_request(@buyer_web_page.user_territory.user, @profile.display_name, @request_information) 
      # sending email through Resque
      @no_error = true
      @profile.display_name.split(",")[0] == "(private)" ? @profile_display_name = "(private) #{@profile.private_display_name}" : @profile_display_name = @profile.display_name

      Resque.enqueue(InvestorRequestNotificationWorker,@buyer_web_page.user_territory.user.id, @profile_display_name, @request_information.name, @request_information.phone, @request_information.email, @request_information.message, @request_information.reason,buyer_website_link, @buyer_web_page.new_format_url)

      flash.now[:request_notice] = "Request information sent successfully."
    else
      @no_error = false
    end
  end
end


