class BuyerWebsitesController < ReiWebsitesController

  before_filter :login_required
  before_filter :check_territory_limit, :only => [:step1]
  before_filter :set_site_type
  before_filter :check_zip, :only => [:update_buying_areas]

  layout "application"

  #  uses_yui_editor(:only=>[:new,:set_up,:step3,:edit,:update,:create])

  PROPERTIES_PER_PAGE = "5"

  before_filter do  |controller|
    controller.send(:check_investor_role,[BASIC_USER_CLASS[:uc1_type],BASIC_USER_CLASS[:uc2_type]])
  end
  
  def show
    @user_company_image = UserCompanyImage.find_by_user_id(current_user.id)
    @user_company_info = UserCompanyInfo.find_by_user_id(current_user.id)
    @buyer_web_page = BuyerWebPage.find_by_domain_permalink_text("greathome")  # (params[:permalink_text])

    if params[:preview]
      @territory = @buyer_web_page.user_territory.territory
      @territory_param_name = @territory.territory_name
      @territory_reim_name = @territory.reim_name
      @business_name = @user_company_info.business_name unless @user_company_info.nil?
      @page_number = (params[:per_page] || "1").to_i
      @page_number = @page_number > 0 ? @page_number : 1
      @map = GMap.new("preview_results_map_div")
      #get_gmap_setting(params[:zip_code])
      @zip_code_array = Zip.get_zips_for_territory(@territory.id)
      @center_zip_code = Zip.get_center_latlng(@buyer_web_page)
      default_investor_buyer_web_page_search()
      render :partial => "account/buyer_webpage_preview", :layout => "investor_web_page" and return
    elsif params[:preview_sp]
      render :partial => "account/buyer_squeeze_webpage_preview", :layout => false and return
    end

    redirect_to :action => :set_up
  end

  def new
    redirect_to :action => :set_up
  end

  def edit
    @buyer_web_page = BuyerWebPage.find_by_id(params[:id])
    params = Hash.new
    params[:reim_domain_name] = @buyer_web_page.my_website.domain_name
    if @buyer_web_page.having?
      params[:having_domain_name] = @buyer_web_page.my_website.domain_name
    else
      if @buyer_web_page.my_website.domain_name == "www.ownhome4.us"
        params[:reim_domain_permalink1] = @buyer_web_page.domain_permalink_text
      else
        params[:reim_domain_permalink2] = @buyer_web_page.domain_permalink_text
      end
    end
    @my_website_form = MyWebsiteForm.new.from_hash(params.merge({"domain"=> @buyer_web_page.domain_type, "type"=>"buyer"}))
    @rei_domains = ["www.ownhome4.us", "www.buyhome4.us"]
    if @buyer_web_page
      @domain_name = @buyer_web_page.my_website.domain_name
    else
      redirect_to :action => 'index'
    end
  end

  # Need to make correction on association based
  # Not working
  def set_up
    buyer_websites = current_user.user_territories.map{|x| x.buyer_web_page}.compact
    if buyer_websites.empty?
      @buyer_website = BuyerWebPage.new
    else
      redirect_to :action => 'index'
    end
  end

  def create_buyer_engagement_note
    #@profile = Profile.find(params[:id])
    #@retail_buyer = RetailBuyerProfile.find_by_profile_id(params[:id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if params[:id].blank? && params[:buyer_engagement_note].blank?
    begin
      @profile = Profile.find(params[:id])
      #@retail_buyer = RetailBuyerProfile.find_by_profile_id(params[:id])
      @buyer_engagement_note = @profile.buyer_engagement_infos.new(params[:buyer_engagement_note])
      if @buyer_engagement_note.save!
        flash[:notice] = 'buyer Note created successfully'
        redirect_to :action=>"buyer_lead_engagement",:id=>params[:id]
      else
        render :action => "add_buyer_notes", :id=>params[:id]
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def create
    @buyer_web_page = BuyerWebPage.new(params[:buyer_web_page])
    my_website = @buyer_web_page.build_my_website(:domain_name => params[:domain_name], :user_id => current_user.id)
    @user_territory = UserTerritory.find(:first , :conditions => { :user_id => current_user.id, :territory_id => params[:user_territory][:territory_id]}) || UserTerritory.create(:user_id => current_user.id, :territory_id => params[:user_territory][:territory_id])

    @my_webpages = MyWebsite.find_all_by_user_id_and_site_type(current_user.id, "BuyerWebPage")
    @my_webpages.each do |my_webpage|
      @flag = true if my_webpage.site.domain_permalink_text == @buyer_web_page.domain_permalink_text && my_webpage.domain_name == params[:domain_name]
    end
  if !@flag
    if @user_territory.save
      @buyer_web_page.user_territory_id = @user_territory.id
      if params["buyer_web_page"]["domain_type"] == 'having'
        @buyer_web_page.domain_permalink_text = domain_permalink_text(params)
      end

      if @buyer_web_page.save
        my_website.save
        flash[:notice] = 'Buyer Website was successfully created.'

        if params["buyer_web_page"]["domain_type"] == MyWebsiteForm::DOMAIN_TYPE[:having] ||  params["buyer_web_page"]["domain_type"] == MyWebsiteForm::DOMAIN_TYPE[:buying]
          enter_domain_name
        end
      else
        flash[:error] = "Error occured while creating buyer site. Please try again"
      end
      redirect_to :action => :index
    else
      @user_territory = UserTerritory.new
      @territories = Array.new
      @states = State.find(:all,:conditions => ["name is not null"], :order=>:name)
      render :action => :step2
    end
  else
    flash[:error] = "Already a Buyer Website with the above URL exists"
    redirect_to :action => :index
  end
  end

  def update
    @buyer_web_page = BuyerWebPage.find_by_id(params[:id])

    if @buyer_web_page.update_attributes(params[:buyer_web_page])
      flash[:notice] = 'Buyer Website was successfully updated.'
      enter_domain_name if @buyer_web_page.having_or_buying?
      redirect_to :action => :index
    else
      @domain_name = @buyer_web_page.my_website.domain_name
      render :action => :edit
    end
  end

  def destroy
    if @buyer_website = BuyerWebPage.find_by_id(params[:id])
      domain_type = @buyer_website.domain_type
      if BuyerWebPage.find_all_by_user_territory_id(@buyer_website.user_territory_id).size > 1
        @buyer_website.destroy
      else
        @buyer_website.user_territory.destroy
      end
      
      enter_domain_name if (domain_type == MyWebsiteForm::DOMAIN_TYPE[:having] || domain_type == MyWebsiteForm::DOMAIN_TYPE[:buying])
      flash[:notice] = "Website deleted successfully."
    end
    redirect_to :action => :index
  end

  # Territory Selection step
  # Should pass step 1 user preferences here
  def step2
    @my_website_form = MyWebsiteForm.new
    @my_website_form.from_hash(params[:my_website_form])
    if @my_website_form.valid?
      @user_territories = current_user.user_territories.select{|x| !x.buyer_web_page.nil?}
      @max_no_of_territories = current_user.number_of_territory.blank? ? 3 : current_user.number_of_territory.to_i
      if @user_territories.size > ( @max_no_of_territories - 1 )
        redirect_to :action => :buyer_webpage
      else
        @user_territory = UserTerritory.new
        @territories = Array.new
        # @states = State.find(:all,:conditions => ["name is not null"], :order=>:name)
        @states = Array.new
      end
    else
      @rei_domains = ["www.ownhome4.us", "www.buyhome4.us"]
      @steps = 3
      render :template => "rei_websites/step1"
    end
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end

  # Site Configurations (title & permalink etc..)
  # Should pass step 1 & step 2 user preferences here
  # After this step buyer website gets created
  def step3
    @my_website_form = MyWebsiteForm.new
    @my_website_form.from_hash(params[:my_website_form])
    params["state_code"]["state_code"] = "CA" if !params[:country].blank? and params[:country][:country] == "CA"
    if params["state_code"]["state_code"].empty? || params["user_territory"]["territory_id"].empty?
      error_msg = params[:country][:country] == "CA" ? 'Please select province of your buyer website.' : 'Please select state & territory of your buyer website.'
    elsif current_user.territory_exists?(params["user_territory"]["territory_id"])
      error_msg = params[:country][:country] == "CA" ? 'Province already exists. Choose some other province.' : 'Territory already exists. Choose some other territory.'
    end
    
    if error_msg
      @user_territory = UserTerritory.new
      @country = params[:country][:country]
      if @country == "CA"
       @territories = Territory.find(:all, :conditions=>["country = ? ", "ca"],:order=>:territory_name)
      else
        @state_id = params[:state_code][:state_code]
        @territories = Territory.find(:all, :conditions=>["state_id = ? ", @state_id],:order=>:territory_name)
        @states = State.find(:all,:conditions => ["name is not null and country = ?",@country], :order => :name)
      end
      @user_territory.errors.add('user_id', error_msg)
      render :action => "step2"
    else
      @buyer_web_page = BuyerWebPage.new
      set_buyer_webpage_fields
    end
  end
  
  def territory_helper
    @states = State.find(:all,:conditions => ["name is not null"], :order=>:name)
    @counties = Array.new
    if !request.xhr?
      @user_territories = current_user.user_territories.select{|x| !x.buyer_web_page.nil?}
      @user_territory = UserTerritory.new
      @max_no_of_territories = current_user.number_of_territory.blank? ? 3 : current_user.number_of_territory.to_i
    else
      render :partial => "territory_helper", :layout => false
    end
  rescue Exception => e
    ExceptionNotifier.deliver_exception_notification( e, self, request, params)
    render :file => "#{RAILS_ROOT}/public/404.html"
  end
  
  def create_new_buyer_profile
    begin
      @buyer_profile = current_user.buyer_profiles.new(params[:buyer_profile])
      @buyer_buyer = @buyer_profile.buyer_buyer_profile.build(params[:buyer_buyer])
      @buyer_profile.buyer_website_id = current_user.buyer_websites.first.id unless current_user.buyer_websites.blank?
      if @buyer_profile.save and @buyer_buyer.save
        create_or_update_buyer_owner
        buyer_sequence = assign_responder_seq_to_the_buyer_profile
        send_buyer_responder_sequence_notification(buyer_sequence)
        flash[:notice] = 'New Buyer was successfully created.'
        redirect_to :action => "buyer_lead_full_page_view", :id => @buyer_profile.id
      else
        render :action => "add_new_buyer"
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp, self, request, params)
    end
  end
  
  def update_buyer_profile
    begin
      render :file => "#{RAILS_ROOT}/public/404.html" and return if params[:buyer_profile].blank?
      @buyer_buyer = @buyer_profile.buyer_buyer_profile[0]
      if @buyer_profile.update_attributes(params[:buyer_profile])
        create_or_update_buyer_owner
        flash[:notice] = 'Buyer info updated successfully'
        redirect_to :action=>"buyer_lead_full_page_view",:id => @buyer_profile.id
      else
        render :action=>"buyer_lead_full_page_view",:id => @buyer_profile.id
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end
  
  def buyer_website_example

  end
  
  def update_domain
    @my_website_form = MyWebsiteForm.new
    @my_website_form.from_hash(params[:my_website_form])
    if @my_website_form.valid?
      if buyer_web_page = BuyerWebPage.find_by_id(params['buyer_site_id'])
        having_true = buyer_web_page.having?
        domain_name = params["my_website_form"]["having_domain_name"]
        if domain_name.empty? && params["my_website_form"]["reim_domain_name"]
          domain_name = params["my_website_form"]["reim_domain_name"]
        end
        # Add domain name javascript validation
        # Permalink text should be lower case letters
        if buyer_web_page.my_website
          buyer_web_page.my_website.update_attributes({:domain_name => domain_name})
        else
          current_user.my_websites.new({ :site_type => "BuyerWebPage", :site_id => params['buyer_site_id'], :domain_name => domain_name }).save
        end
        buyer_web_page.domain_type = params["my_website_form"]["domain"]
        buyer_web_page.domain_permalink_text = extract_permalink_text(params["my_website_form"]).downcase
        # buyer_web_page.permalink_text = nil
        buyer_web_page.save
        enter_domain_name if having_true || (params["my_website_form"]["domain"] == MyWebsiteForm::DOMAIN_TYPE[:having] || params["my_website_form"]["domain"] == MyWebsiteForm::DOMAIN_TYPE[:buying])
      end
      redirect_to :action => :index
    else
      @my_websites = current_user.my_websites.find(:all, :conditions => [ " site_type in (?)",[ @website_type.capitalize + "Website", @website_type.capitalize + "WebPage"]] ) || []

      if has_old_format_webpages?
        @rei_domains = ["www.ownhome4.us", "www.buyhome4.us"]
      end
      
      render :template => "/rei_websites/index"
    end
  end

  def default_investor_buyer_web_page_search()
    territory_profiles = Profile.find(:all, :select => "profiles.*, profile_field_engine_indices.zip_code", :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true and (zip_code in (#{@zip_code_array.join(",")})) and users.activation_code is null  " , :order=>"created_at DESC", :group=>"profile_field_engine_indices.profile_id, profile_field_engine_indices.property_type", :limit => @page_number*5)
    @total_records = @total_records || Profile.count(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true and (zip_code in (#{@zip_code_array.join(",")})) and users.activation_code is null")
    @total_pages = (@total_records / PROPERTIES_PER_PAGE.to_i).to_i + (@total_records % PROPERTIES_PER_PAGE.to_i > 0 ? 1 : 0)
    per_page = @page_number - 1
    @profiles = territory_profiles[per_page.to_i * PROPERTIES_PER_PAGE.to_i,PROPERTIES_PER_PAGE.to_i]
  end
  

  def add_buyer_notes
    @profile = Profile.find(params[:id])
    #@retail_buyer = RetailBuyerProfile.find_by_profile_id(@profile.id)
    @buyer_engagement_note = @profile.buyer_engagement_infos.new()
  end

  def buyer_lead_management
    begin
      search_string = params[:buyer_search_param]
      if !search_string.blank?
        result = search_buyer_leads(search_string)
        @buyer_leads = result.paginate :page => params[:page], :per_page => 10
      else
        @buyer_leads =  current_user.profiles.paginate(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id and status='active' and profiles.deleted_at IS NULL " , :conditions => ["profiles.profile_type_id = ?", ('ce5c2320-4131-11dc-b431-009096fa4c28' || 'ce5c2320-4131-11dc-b433-009096fa4c28')], :order=>"created_at DESC", :group => "permalink", :page => params[:page])
        #@buyer_leads = Profile.paginate(:all, :conditions => {:user_territory_id => current_user.user_territories, :is_archive => false}, :order => "created_at desc", :page => params[:page],:per_page => 10)
      end

      render :partial => "buyer_leads", :layout => false if request.xhr?
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
  end

  def archive_buyer_lead
    begin
      render :file => "#{RAILS_ROOT}/public/404.html" and return if params[:archive_buyer_profiles].nil?
      @profiles = Profile.find_all_by_id(params[:archive_buyer_profiles])
      render :file => "#{RAILS_ROOT}/public/404.html" and return if @profiles.nil?
      if params[:retail_buyers][:delete_reason].blank? or !RetailBuyerProfile::RETAIL_BUYER_PROFILE_DELETE_REASON.include?(params[:retail_buyers][:delete_reason])
        flash.now[:error] = "Please select a reason"
        # @retail_buyers.errors.add("delete_reason", "Please select a reason")
        render :action=>"confirm_archive_buyer_lead", :archive_buyerr_profiles=>@retail_buyers and return
      end
      @profiles.each do |i|
        if !i.retail_buyer_profile.nil?
          if params[:retail_buyers][:delete_reason] == RetailBuyerProfile::RETAIL_BUYER_PROFILE_DELETE_REASON[2]
          
            i_name = i.retail_buyer_profile.first_name + " " + i.retail_buyer_profile.last_name
            i.retail_buyer_profile.destroy
            #flash[:notice] = "Buyer leads deleted successfully."
            ActivityLog.create!({ :activity_category_id=>'cat_buyer_prof_deleted', :user_id=>current_user.id, :description => RetailBuyerProfile::RETAIL_BUYER_PROFILE_DELETE_REASON_NAME[params[:retail_buyers][:delete_reason]], :seller_profile_name => i_name})
          else
            i.retail_buyer_profile.update_attributes(:is_archive=>1, :delete_reason =>params[:retail_buyers][:delete_reason], :delete_comment =>params[:retail_buyers][:delete_comment])
            #flash[:notice] = "Buyer leads deleted successfully."
            log_entry_already_found = ActivityLog.find(:first, :conditions=>["activity_category_id = ? AND seller_profile_id = ? ", 'cat_buyer_prof_deleted', i.retail_buyer_profile.id])
            ActivityLog.create!({ :activity_category_id=>'cat_buyer_prof_deleted', :user_id=>current_user.id, :description => RetailBuyerProfile::RETAIL_BUYER_PROFILE_DELETE_REASON_NAME[params[:retail_buyers][:delete_reason]]}) if !log_entry_already_found
          end
        end
         i.destroy
         flash[:notice] = "Buyer leads deleted successfully."
      end
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    redirect_to :action=>:buyer_lead_management, :page => params[:page]
  end
  
  def confirm_archive_buyer_lead
    if !params[:archive_retail_buyers].nil?
      @profiles = Profile.find_all_by_id(params[:archive_retail_buyers])
      render :file => "#{RAILS_ROOT}/public/404.html" and return if @profiles.nil?
    else
      flash[:error] = "Please select atleast one buyer lead to archive."
      redirect_to :action=>:buyer_lead_management, :page => params[:page]
    end
  end
  
  def buyer_note_full_page_view
    @profile = Profile.find(params[:id])
    #@retail_buyer = RetailBuyerProfile.find_by_profile_id(params[:id])
    @buyer_engagement_note = @profile.buyer_engagement_infos.find_by_id(params[:buyer_note_id])
    render :file => "#{RAILS_ROOT}/public/404.html" and return if @buyer_engagement_note.blank?
  end
  
  def buyer_lead_full_page_view
    #get_buyer_and_buyer_buyer_profile params[:id]
    #@buyer_lead = RetailBuyerProfile.find_by_id(params[:id])
    @buyer_lead = Profile.find_by_id(params[:id])
    @profile = @buyer_lead
    #if @buyer_lead.nil?
     # @profile = Profile.find_by_id(params[:id])
     # @buyer_lead = RetailBuyerProfile.find_by_profile_id(@profile.id)
    #else
     # @profile = Profile.find_by_id(@buyer_lead.profile_id)
     # @buyer_lead.is_new = 0
     # @buyer_lead.save
    #end
    @buyer_lead.is_new = 0
    @buyer_lead.save
    @profile_field = ProfileFieldEngineIndex.profile_id(@buyer_lead.id)
    @is_profile_has_bounced_email_address = BouncedEmail.find_bounced_email_address(@profile_field.notification_email.to_s)
  end
  
  def edit_buying_areas    
    @profile = Profile.find(params[:id])
    if (@profile.investment_type_id == 1 or @profile.investment_type_id == 3)
      @owner_finance_flag = true
    end
    if(@profile.investment_type_id == 2 or @profile.investment_type_id == 3)
      @wholesale_flag = true
    end
    click_route = url_for :controller => 'profiles', :action => 'multi_zip_select_latest'
    @map_params = ZipCodeMap.prepare_map_params('69130', :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
    @zip_code = params[:zip_code] || @profile.zip_code
    @state = params[:state] || @profile.state
    state = State.find(:first, :conditions => ["state_code = ?",@state])
    unless state.blank? 
      @counties = County.get_counties_for_state(state.id).map(&:name).uniq
      @counties.blank? ? Array.new : @counties.map { |county| [county, county]  }  
    else
      @counties = Array.new
    end
    @profile_counties_array = Array.new 
    @profile_counties_array = @profile.county.split(",") if @profile.county.present?
    if @zip_code.blank?
      pfs = ProfileFieldEngineIndex.find_all_by_profile_id(@profile.id)
      arr = String.new
      pfs.each do |i|
        arr << i.zip_code + ','       
      end
      @zip_code = arr.chop     
    end

    @coun  = params[:coun].blank? ? @profile.country.upcase : params[:coun]

    if (@coun == "US") and !@zip_code.blank?
      if @profile.owner?
        @zip_code = @zip_code.split(/[^0-9]+/).first
      end
      
      profile_zip  = @profile.country == "CA" ? ((!params[:coun].blank? and params[:coun] == "US") ? '69130' : @zip_code) : ((!params[:coun].blank? and params[:coun]) == "CA" ? 'G0X 2Z0' : @zip_code)            
      click_route = url_for :controller => 'profiles', :action => @profile.owner? ? 'single_zip_select' : 'multi_zip_select'
      
      @map = ZipCodeMap.prepare_map(profile_zip, :click_route => click_route, :zipcodes_js_source => "$('zip_code').value")
      @boundary_overlays = ZipCodeMap.prepare_boundary_overlays(@zip_code)
      @js = ZipCodeMap.prepare_map_overlay_click_event_handler(click_route, :zipcodes_js_source => "$('zip_code').value") unless @profile.owner?
    else
      @state = params[:state] || @profile.state
      @cities = @profile.country == "US" ? Zip.find(:all, :conditions=>["state = ? and country = ?", @state, "CA"], :order => "city").map(&:city).uniq : Array.new
    end    
  end

  def update_preview_territory
    if !params[:country_id].blank? and params[:country_id] == "CA" 
      @territories = Territory.find(:all, :conditions=>["country = ? ", "ca"],:order=>:territory_name)
      render :partial => 'update_canada_territory_for_preview'        
    else
      @territories = Array.new
      @states = State.find(:all,:conditions => ["name is not null and country = ?",params[:country_id]], :order=>:name)
      render :partial => 'update_us_territory_for_preview'        
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
        page.hide 'direction_links'
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

  def update_buyer_leads_contact
    begin
      @parameters = params
      @profile = Profile.find(params[:id])
      if (params[:firstname].blank?)
        flash[:error] = "first name can't be blank"
        redirect_to  :action => "buyer_lead_full_page_view", :id => params[:id], :retain_values => @parameters and return
      end
      if (params[:lastname].blank?)
        flash[:error] = "last name can't be blank"
        redirect_to  :action => "buyer_lead_full_page_view", :id => params[:id], :retain_values => @parameters and return
      end
      if (params[:phone].blank?)
        flash[:error] = "phone can't be blank"
        redirect_to  :action => "buyer_lead_full_page_view", :id => params[:id], :retain_values => @parameters and return
      end
      if (params[:email_address].blank?)
        flash[:error] = "email can't be blank"
        redirect_to  :action => "buyer_lead_full_page_view", :id => params[:id], :retain_values => @parameters and return
      end
      pfvalue_downc =  params[:email_address].downcase
      if (!params[:email_address].blank?)
        unless ((3..100) === pfvalue_downc.length && pfvalue_downc.match('^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$'))
          flash[:error] = "email format invalid"
          redirect_to  :action => "buyer_lead_full_page_view", :id => params[:id], :retain_values => @parameters and return
        end
      end
      @retail_buyer = RetailBuyerProfile.find_by_profile_id(params[:id])
      if !@retail_buyer.nil?
        @retail_buyer.first_name = params[:firstname]
        @retail_buyer.last_name = params[:lastname]
        @retail_buyer.email_address = params[:email_address]
        @retail_buyer.phone = params[:phone]
        @retail_buyer.alternate_phone = params[:alt_phone]
        @retail_buyer.save!
      end
      
      @profile.profile_fields.each do |pf|
        if( pf.key.eql? 'first_name' ) then
          pf.value = params[:firstname]
          @pf_flag_fn = true
          pf.save!
          break
        end
      end
      @profile.profile_fields.each do |pf|
        if( pf.key.eql? 'last_name' ) then
          pf.value = params[:lastname]
          @pf_flag_ln = true
          pf.save!
          break
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
        if( pf.key.eql? 'notification_phone' ) then
          pf.value = params[:phone]
          @pf_flag_ph = true
          pf.save!
          break
        end
      end
      @profile.profile_fields.each do |pf|
        if( pf.key.eql? 'notification_email' ) then
          pf.value = params[:email_address]
          @pf_flag_email = true
          pf.save!
          break
        end
      end
      if !@pf_flag_ph
        @profile.profile_fields.create(:key=>'notification_phone',:value=>"#{params[:phone]}")
      end
      if !@pf_flag_email
        @profile.profile_fields.create(:key=>'notification_email',:value=>"#{params[:email_address]}")
      end
      if !@pf_flag_fn
        @profile.profile_fields.create(:key=>'first_name',:value=>"#{params[:firstname]}")
      end
      if !@pf_flag_ln
        @profile.profile_fields.create(:key=>'last_name',:value=>"#{params[:lastname]}")
      end
      @profile.profile_nickname = params[:firstname]
      profile_price_value = @profile.is_owner_finance_profile? ? @profile.field_value(:max_dow_pay) : @profile.field_value(:max_purchase_value)
      @profile.private_display_name = sprintf "%s, %s, %s", @profile.profile_nickname, @profile.investment_type.name, profile_price_value
      @profile.save!
      flash[:notice] = "Buyer details updated successfully."
      redirect_to :action => :buyer_lead_full_page_view, :id => @profile.id and return
    rescue Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      redirect_to :action => :buyer_lead_full_page_view, :id => @profile.id and return
    end
  end

  def update_buying_areas
    @profile = Profile.find(params[:id])
    @profile_type = ProfileType.find_by_name("buyer")
    @zip_code = params[:zip_code]
    @fields = ProfileFieldForm.create_form_for(@profile_type.permalink)
    @fields.from_profile_fields(@profile.profile_fields)
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
      render :action => "edit_buying_criteria" and return
    else
      update_buyer_area_related_options(@country_flag, @state_flag, @city_flag, county_string)
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
          flash[:notice] = 'Buying Areas successfully updated.'
          # format.html { redirect_to profile_url(@profile) }
          format.html { redirect_to(:action =>"edit_buying_areas", :id=> @profile.id) and return }
          format.xml  { head :ok }
        else
          format.html redirect_to(:action =>"edit_buying_areas", :id=> @profile.id)
          format.xml  { render :xml => @profile.errors.to_xml }
        end
      end
    end
  end
  
  

  def edit_buying_criteria
    @profile = Profile.find(params[:id])
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
    @fields.contract_end_date = ProfileFieldEngineIndex.contract_end_date(@profile.id)
    @fields.description = @fields.description
    if (@profile.investment_type_id == 1 or @profile.investment_type_id == 3)
      @owner_finance_flag = true
    end
    if(@profile.investment_type_id == 2 or @profile.investment_type_id == 3)
      @wholesale_flag = true
    end
    
    render :action => :edit_buying_criteria , :id => @profile.id
  rescue  Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    handle_error("Error updating your contract date",exp) and return
  end
  
  def update_buying_criteria
    # 1. Capture fields from the request into a form object
    @profile = Profile.find(params[:id])
    @profile_type = @profile.profile_type
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
        render :action => "edit_buying_criteria" and return
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
        @profile.before_save
        unless @investmant_type_flag.blank?
          @zip_code = @zipcode_flag
          update_buyer_area_related_options(@country_flag, @state_flag, @city_flag, @county_flag)
        end
        if @profile.save!
          @profile.update_seller_property_profile unless @profile.seller_property_profile.blank?
        end
        log_activity(:activity_category_id=>'cat_prof_updated', :user_id=>current_user.id, :profile_id=>@profile.id, :session_id=>request.session_options[:id])
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error saving your 'buying criteria' updates",exp) and return
      end
      flash[:notice] = "Buyer's 'Buying criteria' details updated successfully."
      redirect_to :action => :edit_buying_criteria, :id => @profile.id and return
    end
    if (@fields.investment_type_id == "1" or @fields.investment_type_id == 3)
      @owner_finance_flag = true
    end
    if(@fields.investment_type_id == "2" or @fields.investment_type_id == 3)
      @wholesale_flag = true
    end
    # redraw the edit form and render any errors
    render :action => :edit_buying_criteria , :id => @profile.id
  end

  def buyer_lead_match
    @profile = Profile.find(params[:id])
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
    @match_count = @profile.match_count_text(@total_profiles_fetched, @listing_type)
    # indicate that we're using popups on thumbnails
    @uses_yui_lightbox = true
    
    respond_to do |format|
      format.html { render :partial=>"buyer_matches" and return if request.xhr?
        render :action => :buyer_lead_match }
      format.xml  { render :xml => @profile.to_xml }
    end
  end
  
  def scratch_pad
    @buyer_lead = Profile.find(params[:id])
    render :layout=>false
  end
  
  def set_scratch_pad_note
   session[:scratch_pad_note] = params[:note_text_buyer] if session[:scratch_pad_note_when_discard] != params[:note_text_buyer]
    session[:buyer_lead_id] = params[:buyer_lead_id]
    session[:scratch_pad_note_when_discard] = nil
    render :text => 'ok'
  end

  def discard_scratch_pad_note_lightbox
    session[:scratch_pad_note] = nil
    session[:scratch_pad_note_when_discard] = params[:note_text_buyer]
    render :text => false
  end
  
  def save_scratch_pad_info
      begin
        session[:scratch_pad_note] = nil
        @buyer_lead = Profile.find(params[:id])
        #@retail_buyer = RetailBuyerProfile.find(params[:id]) if @retail_buyer.nil?
        #@profile = @retail_buyer.profile
        @buyer_engagement_note = @buyer_lead.buyer_engagement_infos.create(params[:buyer_engagement_info])
        render :text => false
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error trying to redirect. Please try again later or contact support",exp) and return
      end
      
 end
  
  def buyer_lead_engagement
    @profile = Profile.find(params[:id])
    #@retail_buyer = Profile.find(params[:id])
    @buyer_engagement_infos = @profile.buyer_engagement_infos.paginate(:all, :order => "created_at desc",:page => params[:page],:per_page => 10)
    @is_profile_has_bounced_email_address = BouncedEmail.find_bounced_email_address(@profile.profile_field_engine_indices[0].notification_email.to_s)
  end

  def update_territory_block
    if !params[:country_id].blank? and params[:country_id] == "CA"
      @territories = Territory.find(:all, :conditions=>["country = ? ", "ca"],:order=>:territory_name)
      render :partial => 'update_canada_territory_block'
    else
      @territories = Array.new
      @states = State.find(:all,:conditions => ["name is not null and country = ?",params[:country_id]], :order=>:name)
      render :partial => 'update_us_territory_block'
    end
  end

  def update_preview_territory
    if !params[:country_id].blank? and params[:country_id] == "CA"
      @territories = Territory.find(:all, :conditions=>["country = ? ", "ca"],:order=>:territory_name)
      render :partial => 'update_canada_territory_for_preview'
    else
      @territories = Array.new
      @states = State.find(:all,:conditions => ["name is not null and country = ?",params[:country_id]], :order=>:name)
      render :partial => 'update_us_territory_for_preview'
    end
  end

  
  def delete_buyer_note
    begin
      @buyer_engagement_note = BuyerEngagementInfo.find_by_id(params[:buyer_note_id])
      render :file => "#{RAILS_ROOT}/public/404.html" and return if @buyer_engagement_note.blank?
      @buyer_engagement_note.destroy
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
    redirect_to :controller=>'buyer_websites', :action=>'buyer_lead_engagement', :id=>params[:id]
  end
  

  private

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
  
  def update_buyer_area_related_options(pro_country, pro_state, pro_city, county_string)
    # save change
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
      zips = Zip.find(:all, :conditions => ["city =? && state=?",pro_city, pro_state])
      a = String.new
      zips.each do |i|
        a << i.zip.to_s+','
      end

      zip_codes = a.to_s.chop      

      zip = (zip_codes.blank?) ? nil : zip_codes
      @profile.profile_fields.each do |pf|
        
        if( pf.key.eql? 'zip_code' ) then
          pf.value_text = zip
          pf.value = zip
          pf.save!
          break
        end
      end
    end
    
    @profile.country = pro_country
    @profile.state = pro_state
    @profile.city = pro_city
  end

  def domain_permalink_text params
     params["domain_name"].gsub("\.","").downcase
  end

  def check_territory_limit
    user_territories = current_user.user_territories.select{|x| !x.buyer_web_page.nil?}
    max_no_of_territories = current_user.number_of_territory.blank? ? 3 : current_user.number_of_territory.to_i
    if user_territories.size > ( max_no_of_territories - 1 )
      flash[:error] = "You buyer websites limit reached. You can have maximum #{max_no_of_territories} territories."
      redirect_to :action => :index
    end
  end

  def set_buyer_webpage_fields
    if params[:my_website_form][:domain] == MyWebsiteForm::DOMAIN_TYPE[:reim]
      @domain_name = params[:my_website_form][:reim_domain_name].downcase
      @buyer_web_page.domain_type = "reim"
    elsif params[:my_website_form][:domain] == MyWebsiteForm::DOMAIN_TYPE[:having]
      # @buyer_web_page.permalink_text = params[:my_website_form][:having_domain_name].to_s.delete"./"
      @domain_name = params[:my_website_form][:having_domain_name].downcase
      @buyer_web_page.domain_type = "having"
      #Need to add the check for buying domains
    end
    @buyer_web_page.domain_permalink_text = extract_permalink_text(params[:my_website_form]).downcase
  end

  def set_site_type
    @website_type = 'buyer'
  end

  def extract_permalink_text params
    return params["having_domain_name"].gsub("\.","") if params["domain"] == "having"
    permalink = params["reim_domain_permalink1"] if params["reim_domain_name"] == "www.ownhome4.us"
    permalink = params["reim_domain_permalink2"] if params["reim_domain_name"] == "www.buyhome4.us"
    return permalink
  end

  def search_buyer_leads(search_string)
    search = ActsAsXapian::Search.new([Profile, RetailBuyerProfile, ProfileFieldEngineIndex], search_string, {:limit=>10000000})
    
    searched_profiles = []
    search.results.each { |result|
      model_name = result[:model].class.name
      if model_name == "Profile"
        profile =  result[:model]
      elsif model_name == "ProfileFieldEngineIndex"
        profile =  result[:model].profile 
      elsif model_name == "RetailBuyerProfile"
        profile =  result[:model].profile 
      end
      if profile 
        searched_profiles << profile if profile.user_id == current_user.id && (profile.profile_type_id == "ce5c2320-4131-11dc-b431-009096fa4c28" || profile.profile_type_id == "ce5c2320-4131-11dc-b433-009096fa4c28")
      end
    }

    searched_profiles.uniq!
    return searched_profiles
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
