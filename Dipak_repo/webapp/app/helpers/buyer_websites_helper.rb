module BuyerWebsitesHelper

  def field_value(key)
    # TODO: may want to optimize this by caching the fields as a hash?!
    self.profile_fields.each do |field|
      return field.value_text || field.value if field.key == key.to_s
    end

    return nil
  end
  
  def buyer_webpage_link      
    link_to_paste = @domain_name
    if MyWebsiteForm::REIM_DOMAIN_NAME.has_value?(@domain_name) 
      link_to_paste += "/" + @buyer_web_page.domain_permalink_text 
    end
    link_to_paste.downcase
  end

  def map_locations site, params
    options = [['default', '']]
    if site.user_territory.blank?
      Territory.find(params['territory_id']).zips.group_by(&:city).each{|k,v| options << [k, v[0].zip]}
    else
      site.user_territory.territory.zips.group_by(&:city).each{|k,v| options << [k, v[0].zip]}
    end
    options
  end

  
  def get_buyer_lead_name
    unless params[:id].blank?
      @buyer_lead = RetailBuyerProfile.find_by_id(params[:id])
      if @buyer_lead.nil?
        @profile = Profile.find_by_id(params[:id])
        @buyer_lead = RetailBuyerProfile.find_by_profile_id(@profile.id)
      else
        @profile = Profile.find_by_id(@buyer_lead.profile_id)
      end
      
      return "#{@buyer_lead.first_name.to_s + " " + @buyer_lead.last_name.to_s}"
    else
      return "New Buyer"
    end
  end
  
  def investor_business_name
    return (( current_user.user_company_info.blank?) or ( current_user.user_company_info.business_email.blank? )) ? "#{current_user.email}" : "#{current_user.user_company_info.business_email}"
  end
  
  def display_email_with_assign_values_for_buyer_responder(text, buyer_profile, note_type)
    unless buyer_profile.profile_field_engine_indices[0].zip_code.blank?
      zip = buyer_profile.profile_field_engine_indices[0].zip_code
      zip_hash = Zip.find(:first, :conditions => ["zip=?",zip])
      city = zip_hash.blank? ? "" : zip_hash.city.to_s
      state = zip_hash.blank? ? "" : zip_hash.state.to_s
    else
      city = ""
      zip = ""
      state = ""
    end
    #seller_prop_address = buyer_profile.profile_field_engine_indices[0].property_address.blank? ? "" : buyer_profile.profile_field_engine_indices[0].property_address
    sqft_prop = buyer_profile.profile_field_engine_indices[0].square_feet.blank? ? "" : buyer_profile.profile_field_engine_indices[0].square_feet
    beds = buyer_profile.profile_field_engine_indices[0].beds.blank? ? "" : buyer_profile.profile_field_engine_indices[0].beds
    baths = buyer_profile.profile_field_engine_indices[0].baths.blank? ? "" : buyer_profile.profile_field_engine_indices[0].baths
    buyer_website = "this is testing url"
    if  !buyer_profile.field_value(:first_name).blank?
      buyer_first_name = buyer_profile.field_value(:first_name)
    elsif buyer_profile.retail_buyer_profile
      buyer_first_name = buyer_profile.retail_buyer_profile.first_name.to_s
    else
      buyer_first_name = ""
    end
    if  !buyer_profile.field_value(:last_name).blank?
      buyer_last_name = buyer_profile.field_value(:last_name)
    elsif buyer_profile.retail_buyer_profile
      buyer_last_name = buyer_profile.retail_buyer_profile.last_name.to_s
    else
      buyer_last_name = ""
    end
    #buyer_last_name = buyer_profile.last_name.blank? ? "" : buyer_profile.last_name
    buyer_website = buyer_profile.buyer_website_url_for_buyer_leads
    buyer_created = buyer_profile.created_at.to_date.to_s
    discription_text = User.display_email_personalise_value_for_buyer_res(current_user, text.to_s.gsub("{Retail buyer first name}", buyer_first_name).gsub("{Retail buyer last name}", buyer_last_name).gsub("{buyer website HP}",buyer_website).gsub("{buyer website Squeeze}",buyer_website).gsub("{buyer property city}", city.to_s).gsub("{investor buyer website URL}", buyer_website).gsub("{buyer property zip}", zip.to_s).gsub("{property bedrooms}", beds.to_s).gsub("{property baths}", baths.to_s).gsub("{buyer property state}", state).gsub("{property sqft}", sqft_prop.to_s).gsub("{date buyer lead created}", buyer_created).gsub("{last email date}", (Time.now.to_date - 2).strftime("%m/%d/%y")))
    return note_type == "Email" ? discription_text : discription_text.gsub("\n","<br>").gsub(" ","&nbsp;")
    return note_type == "Email" ? discription_text : discription_text.gsub("\n","<br>").gsub(" ","&nbsp;")
  end
  
  def create_website_url(my_website)
    return "" if my_website.blank?
    url_string = my_website.domain_name
    if my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:first] || my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:second]
      url_string = url_string +"/" + my_website.site.permalink_text
    end
    return url_string
  end
  
  def get_style_for_new_property(buyer)
    return buyer.is_new ? "font-weight:bold" : ""
  end
end
