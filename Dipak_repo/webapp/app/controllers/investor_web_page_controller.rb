class InvestorWebPageController < ApplicationController

  before_filter :check_investor_permalink
  layout :selected_layout

  def investor_web_page
  end

  def contact_us
    if request.post?
      @investor_contact_us = InvestorContactUs.new
      @investor_contact_us.from_hash(params['investor_contact_us'])
      if @investor_contact_us.valid?
        # sending email through Resque
         Resque.enqueue(InvestorWebsiteContactWorker,@user.id, @investor_contact_us.name,@investor_contact_us.email,@investor_contact_us.phone,@investor_contact_us.message, @investor_website.id)
        render :partial=>"message_sent", :layout=>false
      else
        render :action=>:contact_us, :layout=>false
      end
    else
      render :layout=>false
    end
  end
  
  def create_buyer_profile
    if request.post?
      begin
        @squeeze_page_opt_in = SqueezePageOptIn.new(params[:squeeze_page_opt_in])
        if @squeeze_page_opt_in.valid?
          @squeeze_page_opt_in.save!
          redirect_to :action => "new_retail_buyer_zipselect", :permalink_text => params["permalink_text"], :first_name => params[:squeeze_page_opt_in][:retail_buyer_first_name], :email => params[:squeeze_page_opt_in][:retail_buyer_email]
          return
        else
          render :action => "investor_web_page", :permalink_text => params["permalink_text"], :layout=>true
        end
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      end
    else
      redirect_to :action => "investor_web_page", :permalink_text => params["permalink_text"] and return
    end
  end
  
  def new_retail_buyer_zipselect
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
    
    render :layout => false
  end

  def new_wholesale_retail_buyer
    county_params= params[:county].blank? ? Array.new : params[:county][:county]  
    if params[:country].to_s.downcase == "ca" or !params[:zip_code].blank? or (!county_params.blank?)
      @retail_buyer = RetailBuyerProfile.new
      @retail_buyer.first_name = params[:first_name] unless params[:first_name].blank?
      @retail_buyer.email_address = params[:email] unless params[:email].blank?
      @profile_type = ProfileType.find_by_permalink("buyer")
      @fields = ProfileFieldForm.create_form_for("buyer")
      @fields.privacy = "public"
      county_string = String.new
      unless county_params.blank?
        county_params.each do |county|
          county_string = county and next if county_string.blank?
          county_string = county_string.to_s+","+county.to_s
        end
      end 
      @fields.county = county_string
      @wholesale_flag = true unless params[:wholesale].blank?
      @owner_finance_flag = true unless params[:owner_finance].blank?
      @fields.zip_code = params[:zip_code]
       coun = params[:country].to_s.downcase == "ca" ? "CA" : "US"
      @fields.country = coun 
      @fields.county = county_string unless county_string.blank?
      @fields.state = params[:state] unless params[:state].blank?
      @fields.city = params[:city][:city] unless params[:city].blank?
      @fields.investment_type_id = InvestmentType.find_by_code('WS').id
      render :layout => false
    else
      redirect_to :action => :new_retail_buyer_zipselect, :permalink_text=>params["permalink_text"]
    end
  end

  def create_retail_buyer
    if request.post?
      @retail_buyer = RetailBuyerProfile.new()
      @wholesale_flag = true unless params[:wholesale].blank?
      @owner_finance_flag = true unless params[:owner_finance].blank?
      @retail_buyer.from_hash(params['retail_buyer'])
      @profile_type = ProfileType.find_by_permalink("buyer")
      @fields = ProfileFieldForm.create_form_for(@profile_type.permalink)
      if !@profile_type.blank? && (@profile_type.permalink == "buyer" || @profile_type.permalink == "buyer_agent")
        params['fields']['contract_end_date'] = (Date.today + 180).to_s(:db) unless params['fields'].blank?
      end
      params['fields']['notification_email'] = @retail_buyer.email_address
      params['fields']['notification_phone'] = @retail_buyer.phone
      params['fields']['notification_active'] = true
      params['fields']['first_name'] = @retail_buyer.first_name
      params['fields']['last_name'] = @retail_buyer.last_name
      @fields.from_hash(params['fields'])
#       @fields.investment_type_id = InvestmentType.find_by_code('WS').id
#       @fields.wholesale_buyer = true
      @fields.privacy = "public"
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
        flash[:notice] = "Please choose appropriate Zip Code" 
        return false
      end
      else
        @fields.zip_code = params['fields'][:zip_code].blank? ? (Zip.find(:first, :conditions => ["city = ?",@fields.city]).zip) : params['fields'][:zip_code]
      end
      if @fields.valid? && @fields.valid_for_property_type? && @retail_buyer.valid?
        @profile = Profile.new
        @profile.country = @fields.country unless @fields.country.blank?
        @profile.state = @fields.state unless @fields.state.blank?
        @profile.city = @fields.city unless @fields.city.blank?
        @profile.private_display_name = @retail_buyer.first_name
        @profile.profile_fields = @fields.to_profile_fields
        @profile.investment_type_id = @fields.investment_type_id
        @profile.profile_type = @profile_type
        @profile.user = @user
        @profile.generate_name
        begin
          Profile.transaction do
            @user.profiles << @profile
            profile_price_value= @profile.is_owner_finance_profile? ? @fields.max_dow_pay : @fields.max_purchase_value
            @profile.private_display_name = sprintf "%s, %s, %s", @retail_buyer.first_name, @profile.investment_type.name, profile_price_value
            @profile.save!
            @retail_buyer.profile_id = @profile.id
            @retail_buyer.save!
            investor_url = request.url.gsub(request.path,"")
            Resque.enqueue(BuyerCreatedFromInvestorWebsiteNotificationWorker, @user.id, @fields, @retail_buyer.id, investor_url)
          end
          rescue Exception => e
          ExceptionNotifier.deliver_exception_notification( e, self, request, params)
          handle_error("Error saving your new profile",e) and return
        end
        redirect_to :action => :thank_you, :permalink_text => params[:permalink_text]
      else
        render :action => :new_wholesale_retail_buyer, :permalink_text=>params["permalink_text"], :coun => @fields.country, :zip_code => @fields.zip_code, :layout=>false
      end
    else
      redirect_to :controller=>:home,:action=>:index
    end
  end
  
  def thank_you
    render :layout => false
  end


private

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
      validate_wholesale
      elsif !params[:owner_finance].nil?
        @fields.investment_type_id = params[:owner_finance]
        validate_owner_finance
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


  def selected_layout
    @investor_website.layout == "modern" ? "investor_webpagetemp2" : "investor_webpage"
  end

  def check_investor_permalink
    @investor_website = InvestorWebsite.find_by_active_permalink(params[:permalink_text])
    render :file => REI_404_PAGE and return if @investor_website.blank?
    get_investor_detail
  end

  def get_investor_detail
    @user = @investor_website.user
    @user_company_image = @user.user_company_image
    @user_company_info  = @user.user_company_info
    @investor_website_image = InvestorWebsiteImage.find_investor_website_image(@investor_website.id)
  end
  
end
