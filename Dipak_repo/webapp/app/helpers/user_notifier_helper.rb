module UserNotifierHelper

  def display_email_intro(email_intro, current_user, retail_buyer_name, 
                          url_parameter, permalink_text, new_format_url)
    return display_email_assign_values(email_intro, current_user, retail_buyer_name, url_parameter, permalink_text, new_format_url).gsub("{Business Name}","#{!current_user.user_company_info.nil? && !current_user.user_company_info.business_name.blank? ? current_user.user_company_info.business_name : '{Business Name}'}")
  end
  
  def display_email_assign_values(text, current_user, retail_buyer_name, 
                                  url_parameter, permalink_text, new_format_url)
       url = REIMATCHER_URL
    {"{Investor first name}"=> "first_name", "{Investor full name}" => "full_name",
      "{Company name}" => "user_company_info.business_name",
      "{Company address}" => "user_company_info.business_address",
      "{Company phone}" => "user_company_info.business_phone",
      "{buyer website HP}" => "user_territories.first",
      "{buyer website Squeeze}" => "user_territories.first",
      "{eBook Download Link}" => "",
      "{Company email}"=>"user_company_info.business_email"}.each_pair do |k, v|
      
      if k ==  "{Company address}"
        if current_user.user_company_info
          value = current_user.user_company_info.business_address + "<br>" + 
            current_user.user_company_info.city  + ",\n" + 
            current_user.user_company_info.state  + ",\n" + current_user.user_company_info.zipcode
        else
          value = k
        end
      elsif k == "{buyer website HP}"
        @user_territories = current_user.user_territories.first
        if !new_format_url.blank?
          value = "<a href='#{new_format_url}'>" + new_format_url + "</a>"
        elsif !url_parameter.nil? || !permalink_text.nil?
          value = "<a href='#{url}#{url_parameter}/#{permalink_text}'>" + url + url_parameter + '/' + permalink_text + "</a>"
        elsif !@user_territories.nil?
          @page = BuyerWebPage.find_by_user_territory_id(@user_territories.id)
          @terr_name = Territory.find(@user_territories.territory_id) 

          if !@page.nil?
            if @page.new_format_url.blank?
  #           !@page.nil? ? value =  "<a href='#{url}investor_buyer_web_page/#{current_user.id}/get_url/'>" + url + "investor_buyer_web_page" + '/' + current_user.id+"/"+"get_url"+"</a>" : value = "" 
              value =  "<a href='#{url}#{@terr_name.reim_name}/#{@page.permalink_text}'>" + url + @terr_name.reim_name + '/' + @page.permalink_text+"</a>"
            else
              value = "<a href='#{@page.new_format_url}'>" + @page.new_format_url + "</a>"
            end
          else
            value = ""
          end
        else
          value = ""
        end
      elsif k == "{buyer website Squeeze}"
        @user_territories = current_user.user_territories.first
        if !new_format_url.blank?
          squeeze_url = new_format_url + "/2"
          value = "<a href='#{squeeze_url}'>" + squeeze_url + "</a>"
        elsif !url_parameter.nil? || !permalink_text.nil?
          @territory = Territory.find_by_reim_name(url_parameter)
          current_user.user_territories.each do |x|
            @sequeeze_page_number = x.sequeeze_page_number if x.territory_id == @territory.id
          end
          value = "<a href='#{url}#{url_parameter}/#{permalink_text}/sp#{@sequeeze_page_number.to_s}' >" + url + url_parameter + '/' + permalink_text + '/sp' + @sequeeze_page_number.to_s + "</a>"
        elsif !@user_territories.nil?
          @page = BuyerWebPage.find_by_user_territory_id(@user_territories.id)
          @terr_name = Territory.find(@user_territories.territory_id) 
          if !@page.nil?
            if @page.new_format_url.blank?
              @sequeeze_page_number = @user_territories.sequeeze_page_number
              value = "<a href='#{url}#{@terr_name.reim_name}/#{@page.permalink_text}/sp#{@sequeeze_page_number.to_s}' >" + url + @terr_name.reim_name + '/' + @page.permalink_text + '/sp' + @sequeeze_page_number.to_s + "</a>"
            else
              squeeze_url = @page.new_format_url + "/2"
              value = "<a href='#{squeeze_url}'>" + squeeze_url + "</a>"
            end
          else
            value = ""
          end
#           !@page.nil? ? value = "<a href='#{url}investor_buyer_web_page/#{current_user.id}/get_url/#{@user_territories.sequeeze_page_number.to_s}'>" + url + "investor_buyer_web_page" + '/' + current_user.id+"/"+"get_url/" + "sp" + "</a>" : value = ""
        else
          value = ""
        end

      elsif k == "{eBook Download Link}"
        value = "http://budurl.com/OwnerFinanceGuidev1"
      else
        value = current_user.user_company_info ? eval("current_user."+v) : k
      end
      text = text.gsub(k, value)
    end
    retail_buyer = current_user.profiles.first ? current_user.profiles.first.retail_buyer_profile : nil
    text.gsub("{Retail buyer first name}", retail_buyer_name).gsub("{Buyer first name}", retail_buyer_name)
  end
  
  def display_email_closing(email_closing, current_user, retail_buyer_name, url_parameter, permalink_text, new_format_url)
    business_name = !current_user.user_company_info.nil? && !current_user.user_company_info.business_name.blank?  ? current_user.user_company_info.business_name : '{Business Name}'
    business_address = !current_user.user_company_info.nil? && !current_user.user_company_info.business_address.blank?  ? current_user.user_company_info.business_address : '{Business Address}'
    business_phone = !current_user.user_company_info.nil? && !current_user.user_company_info.business_phone.blank?  ? current_user.user_company_info.business_phone : '{Business Phone}'
    return display_email_assign_values(email_closing, current_user, retail_buyer_name, url_parameter, permalink_text, new_format_url).gsub("{Business Name}",business_name).gsub("{Business Address}",business_address).gsub("{Business Phone}",business_phone)
  end

  def display_email_with_assign_values(investor, text, buyer_first_name)
    return User.display_email_assign_values(investor, text.to_s.gsub("{Retail buyer first name}", buyer_first_name.to_s).gsub("{Buyer first name}", buyer_first_name.to_s))
  end

  def display_email_with_assign_values_for_seller_responder(investor, text, seller_profile, seller_property_profile)
    city, zip, state = get_city_state_zip_for_seller_lead(seller_property_profile)
    seller_prop_address = seller_property_profile.property_address.blank? ? "" : seller_property_profile.property_address

    sqft_prop = seller_property_profile.square_feet.blank? ? "" : seller_property_profile.square_feet

    beds = seller_property_profile.beds.blank? ? "" : seller_property_profile.beds

    baths = seller_property_profile.baths.blank? ? "" : seller_property_profile.baths

    seller_last_name = seller_profile.last_name.blank? ? "" : seller_profile.last_name

    seller_website = seller_profile.seller_website.blank? ? "" : create_website_url(seller_profile.seller_website.my_website)
    seller_created = seller_profile.created_at.to_date.to_s

    amps_owners_guide = "<a href='http://reimatcher.com.s3.amazonaws.com/seller/AMP-Homeowner-Guide.pdf'>AMPS Homeowners Guide</a>"
    seller_site_squeeze = "<a href='#{seller_website}/#{seller_profile.id}'>#{seller_website}</a>"
    site = seller_profile.seller_website
    if !site.blank? && site.seller_magnet && site.having?
      seller_site_squeeze = "<a href='#{seller_website}/m/#{site.permalink_text}/#{seller_profile.id}'>#{seller_website}</a>"
    end
  
    return User.display_email_personalise_value_for_seller_res(investor, text.to_s.gsub("{seller first name}", seller_profile.first_name).gsub("{seller last name}", seller_last_name).gsub("{seller property city}", city.to_s).gsub("{investor seller website URL}", seller_website).gsub("{seller website}", seller_website).gsub("{seller property zip}", zip.to_s).gsub("{seller property address}", seller_prop_address.to_s).gsub("{property bedrooms}", beds.to_s).gsub("{property baths}", baths.to_s).gsub("{seller property state}", state).gsub("{property sqft}", sqft_prop.to_s).gsub("{date seller lead created}", seller_created).gsub("{last email date}", (Time.now.to_date - 2).strftime("%m/%d/%y")).gsub("{AMPS Homeowners Guide}", amps_owners_guide).gsub("{seller website - squeeze}", seller_site_squeeze))
  end

  def profile_field_values(profile_fields, key)
    profile_fields.each do |profile_field|
      if profile_field.key == key
        value = profile_field.value
        if profile_field.key == "beds" || profile_field.key == "baths"
          if profile_field.key == "baths"
            if value.to_s == "3"
              value = "2"
            elsif value.to_s == "5"
              value = "3"
            elsif value.to_s == "7"
              value = "4"
            end
          end
          return value.to_s + "+" if value != "any" && !value.blank?
        end
        return value
      end
    end
  end

  def display_baths_when_retail_buyer_created(bath_value)
    value = bath_value
    if bath_value.to_s == "3"
      value = "2+"
    elsif bath_value.to_s == "5"
      value = "3+"
    elsif bath_value.to_s == "7"
      value = "4+"
    elsif bath_value.to_s == "1"
      value = "1+"
    end
    return value
  end
  
  def display_buyer_criteria_for_profile(email_body, profile_id)
    begin
      profile = Profile.find(profile_id)
      profile_fields = profile.profile_fields
      if profile.is_owner_finance_profile?
        email_body.gsub("{Buyer criteria}", "<b>Zip Code:</b>  &nbsp; #{profile_field_values(profile_fields, "zip_code")}<br /><b># Beds:</b> &nbsp; #{profile_field_values(profile_fields, "beds")}<br /><b># Baths:</b>  &nbsp; #{profile_field_values(profile_fields, "baths")}<br /><b>Sqft Range:</b>  &nbsp; #{profile_field_values(profile_fields, "square_feet_min")} &nbsp; - &nbsp; #{profile_field_values(profile_fields, "square_feet_max")}<br /><b>Max Monthly Payment:</b>  &nbsp; $#{profile_field_values(profile_fields, "max_mon_pay")}<br /><b>Max Down Payment:</b>  &nbsp; $#{profile_field_values(profile_fields, "max_dow_pay")}<br />")
      elsif profile.is_wholesale_profile?
        email_body.gsub("{Buyer criteria}", "<b>Zip Code:</b>  &nbsp; #{profile_field_values(profile_fields, "zip_code")}<br /><b># Beds:</b> &nbsp; #{profile_field_values(profile_fields, "beds")}<br /><b># Baths:</b>  &nbsp; #{profile_field_values(profile_fields, "baths")}<br /><b>Sqft Range:</b>  &nbsp; #{profile_field_values(profile_fields, "square_feet_min")} &nbsp; - &nbsp; #{profile_field_values(profile_fields, "square_feet_max")}<br /><b>Max Purchase Price:</b>  &nbsp; $#{profile_field_values(profile_fields, "max_purchase_value")}<br /><b>% ARV - Repairs:</b>  &nbsp; #{profile_field_values(profile_fields, "arv_repairs_value")}<br />")
      else
        email_body.gsub("{Buyer criteria}", "<b>Zip Code:</b>  &nbsp; #{profile_field_values(profile_fields, "zip_code")}<br /><b># Beds:</b> &nbsp; #{profile_field_values(profile_fields, "beds")}<br /><b># Baths:</b>  &nbsp; #{profile_field_values(profile_fields, "baths")}<br /><b>Sqft Range:</b>  &nbsp; #{profile_field_values(profile_fields, "square_feet_min")} &nbsp; - &nbsp; #{profile_field_values(profile_fields, "square_feet_max")}<br /><b>Max Monthly Payment:</b>  &nbsp; $#{profile_field_values(profile_fields, "max_mon_pay")}<br /><b>Max Down Payment:</b>  &nbsp; $#{profile_field_values(profile_fields, "max_dow_pay")}<br /><b>Max Purchase Price:</b>  &nbsp; $#{profile_field_values(profile_fields, "max_purchase_value")}<br /><b>% ARV - Repairs:</b>  &nbsp; #{profile_field_values(profile_fields, "arv_repairs_value")}<br />")
      end
    rescue Exception=>exp
      #Taking action if any of profile info fails
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"BuyerProfileWelcomeNotification")
      buyer_welcome_logger=Logger.new("#{RAILS_ROOT}/log/welcome_buyer_fails_notification.log")
      buyer_welcome_logger.info "New Buyer welcome Email could not be sent to this buyer profile creator  #{profile_id} and #{profile}"
      return email_body
    end
  end

  def display_beds_when_retail_buyer_created(bed_value)
    return bed_value if bed_value.to_s == "any"
    return bed_value.to_s + "+"
  end

  def property_full_view_path(user,url, profile)
    unless @user.user_territories.nil?
       @active_buyer_web=Array.new
       @user.user_territories.find(:all).each do |user_territory|
       buyer_web_page = user_territory.buyer_web_page
         unless buyer_web_page.nil?
           @active_buyer_web << buyer_web_page if user_territory.buyer_web_page.active==true
         end
       end
     unless @active_buyer_web.nil?
        @first_active_buyer_web = @active_buyer_web.first
        if @first_active_buyer_web.new_format_url
          url_full_view = @first_active_buyer_web.new_format_url + "/" +  profile.property_type + "/" +  profile.id + "/full_property_view_latest"
        else
          territory_name = @first_active_buyer_web.user_territory.territory.reim_name
          permalink_text = @first_active_buyer_web.permalink_text
          url_link = url.to_s + territory_name.to_s + "/" + permalink_text.to_s
          url_full_view = url_link + "/" +  profile.property_type + "/" +  profile.id + "/full_property_view"
        end
        return "<a href=#{url_full_view}>Full Property View</a>"
      else
        return ''
      end
    else
      return ''
    end
  end

  def property_full_view_path_for_retail_buyer(buyer_profile, url, profile)
     @first_active_buyer_web = buyer_profile.retail_buyer_profile.user_territory.buyer_web_page
     unless @first_active_buyer_web.nil?
        if @first_active_buyer_web.new_format_url_for_retail_buyer
          url_full_view = @first_active_buyer_web.new_format_url_for_retail_buyer + "/" +  profile.property_type + "/" +  profile.id + "/full_property_view_latest"
        else
          territory_name = @first_active_buyer_web.user_territory.territory.reim_name
          permalink_text = @first_active_buyer_web.permalink_text
          url_link = url.to_s + territory_name.to_s + "/" + permalink_text.to_s
          url_full_view = url_link + "/" +  profile.property_type + "/" +  profile.id + "/full_property_view"
        end
        return "<a href=#{url_full_view}>Full Property View</a>"
     else
       return ''
     end
  end

  def check_retail_buyer(profile_id)
      profile = Profile.find_by_id(profile_id)
      return true if !profile.nil? && !profile.retail_buyer_profile.nil?
      return false
  end

  def create_website_url(my_website)
    return "" if my_website.blank?
    url_string = my_website.domain_name
    if my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:first] || my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:second]
      url_string = url_string +"/" + my_website.site.permalink_text
    end
    return url_string
  end

  def display_seller_website_link
    return create_website_url(@seller_profile.seller_website.my_website)
  end

  def display_address_with_city_and_zipcode
    city, zip, state = get_city_state_zip_for_seller_lead(@seller_property_profile)
    return "#{@seller_property_profile.property_address}, #{city}, #{state}, #{zip}"
  end

  def set_baths_value(seller_property_profile)
    unless seller_property_profile.baths.blank?
        case
          when seller_property_profile.baths == 1 then return "1"
          when seller_property_profile.baths == 1.5 then return "1 1/2"
          when seller_property_profile.baths == 2 then return "2"
          when seller_property_profile.baths == 2.5 then return "2 1/2"
          when seller_property_profile.baths == 3 then return "3"
          when seller_property_profile.baths == 4 then return "4"
          when seller_property_profile.baths == 5 then return "5"
          when seller_property_profile.baths == 6 then return "6+"
        end
    else
        return 
    end
  end

  def create_investor_website_url(investor_website_id)
    investor_website = InvestorWebsite.find_by_id(investor_website_id)
    return "" if investor_website.blank?
    return "" if investor_website.my_website.blank?
    if investor_website.domain_type == MyWebsiteForm::DOMAIN_TYPE[:reim]
      return investor_website.my_website.domain_name +"/" + investor_website.permalink_text
    else
      return investor_website.my_website.domain_name.to_s.downcase
    end
  end

private

  def get_city_state_zip_for_seller_lead(seller_property_profile)
    unless seller_property_profile.zip_code.blank?
      zip = seller_property_profile.zip_code
      zip_hash = Zip.find(:first, :conditions => ["zip=?",zip])
      city = zip_hash.blank? ? "" : zip_hash.city.to_s
      state = zip_hash.blank? ? "" : zip_hash.state.to_s
    else
      city = ""
      zip = ""
      state = ""
    end
    return city, zip, state
  end

end
