module SellerWebsitesHelper
  
def create_website_url(my_website)
    return "" if my_website.blank?
    url_string = my_website.domain_name
    if my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:first] || my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:second]
      url_string = url_string +"/" + my_website.site.permalink_text
    end
      return url_string
  end

  def company_name
    user_company_info = current_user.user_company_info
    if !user_company_info.nil?
      return user_company_info.business_name 
    else
     return "{Subscriber Company name}"
    end
  end

  def get_action_for_seller_tab
    if params[:id].blank?
      if session["profile_id"].blank?
        return add_new_seller_seller_websites_path
      else
        return add_new_seller_seller_websites_path(:profile_id => session["profile_id"])
      end
    else 
      return seller_lead_full_page_view_seller_website_path(params[:id])
    end
  end

  def display_email_with_assign_values_for_seller_responder(text, seller_profile, note_type)

    unless seller_profile.seller_property_profile[0].zip_code.blank?
      zip = seller_profile.seller_property_profile[0].zip_code
      zip_hash = Zip.find(:first, :conditions => ["zip=?",zip])
      city = zip_hash.blank? ? "" : zip_hash.city.to_s
      state = zip_hash.blank? ? "" : zip_hash.state.to_s
    else
      city = ""
      zip = ""
      state = ""
    end
      seller_prop_address = seller_profile.seller_property_profile[0].property_address.blank? ? "" : seller_profile.seller_property_profile[0].property_address
      sqft_prop = seller_profile.seller_property_profile[0].square_feet.blank? ? "" : seller_profile.seller_property_profile[0].square_feet
      beds = seller_profile.seller_property_profile[0].beds.blank? ? "" : seller_profile.seller_property_profile[0].beds
      baths = seller_profile.seller_property_profile[0].baths.blank? ? "" : seller_profile.seller_property_profile[0].baths
#       seller_website = "this is testing url"
      seller_last_name = seller_profile.last_name.blank? ? "" : seller_profile.last_name
      seller_website = seller_profile.seller_website.blank? ? "" : create_website_url(seller_profile.seller_website.my_website)
      seller_created = seller_profile.created_at.to_date.to_s

    amps_owners_guide = "<a href='http://reimatcher.com.s3.amazonaws.com/seller/AMP-Homeowner-Guide.pdf'>AMPS Homeowners Guide</a>"
    seller_site_squeeze = "<a href='http://#{seller_website}/#{seller_profile.id}'>#{seller_website}</a>"
    site = seller_profile.seller_website
    if !site.blank? && site.seller_magnet && site.having?
      seller_site_squeeze = "<a href='http://#{seller_website}/m/#{site.permalink_text}/#{seller_profile.id}'>#{seller_website}</a>"
    end

    discription_text = User.display_email_personalise_value_for_seller_res(current_user, text.to_s.gsub("{seller first name}", seller_profile.first_name).gsub("{seller last name}", seller_last_name).gsub("{seller property city}", city.to_s).gsub("{investor seller website URL}", seller_website).gsub("{seller website}", seller_website).gsub("{seller property zip}", zip.to_s).gsub("{seller property address}", seller_prop_address.to_s).gsub("{property bedrooms}", beds.to_s).gsub("{property baths}", baths.to_s).gsub("{seller property state}", state).gsub("{property sqft}", sqft_prop.to_s).gsub("{date seller lead created}", seller_created).gsub("{last email date}", (Time.now.to_date - 2).strftime("%m/%d/%y")).gsub("{AMPS Homeowners Guide}", amps_owners_guide).gsub("{seller website - squeeze}", seller_site_squeeze))
    return note_type == "Email" ? discription_text : discription_text.gsub("\n","<br>").gsub(" ","&nbsp;")
  end

  def get_seller_lead_name
    unless params[:id].blank?
      return "#{@seller_profile.first_name.to_s + " " + @seller_profile.last_name.to_s}"
    else
      return "New Seller"
    end
  end

  def get_responder_sequence_name(seller_profile)
    unless seller_profile.seller_property_profile[0].blank?
      if seller_profile.seller_property_profile[0].responder_sequence_assign_to_seller_profile.blank?
        return "None"
      elsif !seller_profile.seller_property_profile[0].responder_sequence_subscription
        return SellerResponderSequence::SEQUENCE_NAME["do_not_call"]
      else
        return SellerResponderSequence::SEQUENCE_NAME[seller_profile.seller_property_profile[0].responder_sequence_assign_to_seller_profile.seller_responder_sequence.sequence_name]
      end
    end
  end

  def get_style_for_new_property(seller_profile)
    return "" if seller_profile.seller_property_profile.blank?
    return seller_profile.seller_property_profile[0].is_new ? "font-weight:bold" : ""
  end

  def investor_business_name
    return (( current_user.user_company_info.blank?) or ( current_user.user_company_info.business_email.blank? )) ? "#{current_user.email}" : "#{current_user.user_company_info.business_email}"
  end

  def get_date_created
    unless @seller_profile.created_at.blank?
      return @seller_profile.date_created.blank? ? @seller_profile.created_at.strftime("%D - %X") : @seller_profile.date_created
    else
      return Time.now.strftime("%D - %X")
    end
  end

  def seller_property_last_payment_made
    return @seller_financial_loan_one_info.last_payment_date.blank? ? @seller_property.last_payment_made : @seller_financial_loan_one_info.last_payment_date
  end
  
  def is_seller_profile_have_bounced_emails
    return ( @seller_property.seller_engagement_infos.find_by_note_type("Email") and is_email_is_bouced_email(@seller_profile.email.to_s) ) ? true : false
  end
  
  def is_note_type_is_email(note_type)
    return note_type == "Email" ? true : false
  end
end
