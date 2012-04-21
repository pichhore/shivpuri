module InvestorWebsitesHelper

  def create_website_url(my_website)
    return "" if my_website.blank?
    return "" if my_website.site.blank?
    if my_website.site.domain_type == MyWebsiteForm::DOMAIN_TYPE[:reim]
      return my_website.domain_name + "/" + my_website.site.permalink_text
    else
      return my_website.domain_name.to_s.downcase
    end
  end



  def buyer_link_name_former(my_website)
    if !my_website.nil?
      buyer_website = BuyerWebPage.find_by_id(my_website.site_id)
      territory = buyer_website.user_territory.territory.reim_name.gsub(/[_]/," ")
      return territory
    else
      return ""
    end
  end


end
