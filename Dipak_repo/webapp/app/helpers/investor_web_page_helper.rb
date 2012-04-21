module InvestorWebPageHelper

  def company_name
    return @user_company_info.business_name unless @user_company_info.nil?
  end

  def business_name_and_address
    if !@user_company_info.nil? and !@user_company_info.business_address.blank?
      return "#{@user_company_info.business_name} <br /> #{@user_company_info.business_address},  #{@user_company_info.city.to_s + ", "+ @user_company_info.state.to_s + " " + @user_company_info.zipcode.to_s}"
    end
  end


  def social_media_for_investor_website(permalink, site_type)
    
    media_icons = {
      1 => 'iconFacebook.png',
      2 => 'iconLinkedIn.png',
      3 => 'iconYouTube.png',
      4 => 'iconTwitter.png'
    }
    if site_type == 'seller'
      seller_website = SellerWebsite.find_by_permalink_text(permalink)
      accounts = seller_website.user.social_media_accounts
      site_type_id = 2
    elsif site_type == 'buyer'
      buyer_website = BuyerWebPage.find_by_domain_permalink_text(permalink)
      accounts = buyer_website.my_website.user.social_media_accounts
      site_type_id = 1
    elsif site_type == 'inv_profile'
      accounts = SocialMediaAccount.find(:all, :conditions => {:user_id => permalink, :site_type_id => 1})
      site_type_id = 1
    elsif site_type == 'investor'
      investor_website = InvestorWebsite.find_by_permalink_text(permalink)
      accounts = investor_website.my_website.user.social_media_accounts
      site_type_id = 1
    end
    
    icons = ""
    accounts.each do |account|
      if !account.url.blank? && account.site_type_id == site_type_id
        icons << '<a href=http://'+ account.url.gsub(/\b(.*:\/\/)/,"") + ' target="_blank"><img src="/images/social_media/' + media_icons[account.url_type_id] + '" width="25" height="25" ></a>   '
      end
    end
    return icons
  end

  def business_phone
    return @user_company_info.business_phone unless @user_company_info.nil?
  end

  def first_active_buyer_web_page
    unless @user.user_territories.nil?
      @active_buyer_web=Array.new
      @user.user_territories.find(:all).each do |user_territory|
        buyer_web_page = user_territory.buyer_web_page
        unless buyer_web_page.nil?
          @active_buyer_web << buyer_web_page if user_territory.buyer_web_page.active==true
        end
      end
      unless @active_buyer_web.blank?
        @first_active_buyer_web = @active_buyer_web[0]
        if @first_active_buyer_web.new_format_url_for_syndication
          buyer_website_url = @first_active_buyer_web.new_format_url_for_syndication
        else
          territory_name = @first_active_buyer_web.user_territory.territory.reim_name
          permalink_text = @first_active_buyer_web.permalink_text
          buyer_website_url = REIMATCHER_URL.to_s + territory_name.to_s + "/" + permalink_text.to_s
        end
        return buyer_website_url
      else
        return '#'
      end
    else
      return '#'
    end
  end


  def investor_links_display
    @active_websites = []
    investor_links_set1 = ""
    investor_links_set2 = ""
    if !@user.investor_website.investor_website_links.nil?
      
      investor_links_set1 << '<a href='+"#{@user.investor_website.investor_website_links.link_url_1}"+' target="_blank" class="footer_website_link">'+@user.investor_website.investor_website_links.link_name_1+' </a>&nbsp;<br/>' if !@user.investor_website.investor_website_links.link_name_1.nil?
    investor_links_set1 << '<a href='+ "#{ @user.investor_website.investor_website_links.link_url_2}"+' target="_blank" class="footer_website_link">'+@user.investor_website.investor_website_links.link_name_2+' </a>&nbsp;<br/>' if !@user.investor_website.investor_website_links.link_name_2.nil?
    investor_links_set1 << '<a href='+"#{ @user.investor_website.investor_website_links.link_url_3}"+' target="_blank" class="footer_website_link">'+@user.investor_website.investor_website_links.link_name_3+' </a>&nbsp;<br/>' if !@user.investor_website.investor_website_links.link_name_3.nil?

      investor_links_set2 << '<a href='+@user.investor_website.investor_website_links.link_url_4 + ' target="_blank" class="footer_website_link">'+@user.investor_website.investor_website_links.link_name_4+' </a>&nbsp;<br/>' if !@user.investor_website.investor_website_links.link_name_4.nil?
investor_links_set2 << '<a href ='+"#{@user.investor_website.investor_website_links.link_name_5}" +' target="_blank" class="footer_website_link">'+@user.investor_website.investor_website_links.link_name_5+' </a>&nbsp;<br/>' if !@user.investor_website.investor_website_links.link_name_5.nil?
    else
      @user.seller_websites.each do |seller_website|
        unless seller_website.nil?
          @active_websites << seller_website if seller_website.active==true and !seller_website.my_website.blank?
        end
      end

      @user.user_territories.find(:all).each do |user_territory|
        buyer_web_page = user_territory.buyer_web_page
        unless buyer_web_page.nil?
          @active_websites << buyer_web_page if user_territory.buyer_web_page.active==true
        end
      end
      ## need to create anchor tags for this 
      if !@active_websites.empty?
        i=0
        @active_websites.each do | website|
          if !website.nil?
            if i <= 2
              investor_links_set1 <<  '<a href="'+create_website_url(website.my_website)+'" target="_blank">'+"#{create_website_url(website.my_website)}"+'</a>&nbsp; <br/>'
            else
              investor_links_set2 << '<a href="'+create_website_url(website.my_website)+'" target="_blank">'+"#{create_website_url(website.my_website)}"+'</a>&nbsp;<br/>'
            end
            i+=1
          end
        end
      end

    end
    
    return investor_links_set1, investor_links_set2
  end


  def first_active_seller_website
    unless @user.seller_websites.blank?
      @active_seller_web=Array.new
       @user.seller_websites.each do |seller_website|
         unless seller_website.nil?
           @active_seller_web << seller_website if seller_website.active==true and !seller_website.my_website.blank?
         end
       end
     unless @active_seller_web.blank?
        @first_active_seller_web = @active_seller_web[0]
        return create_website_url(@first_active_seller_web.my_website)
      else
        return '#'
      end
    else
      return '#'
    end
  end

  def create_website_url(my_website)
    return "#" if my_website.blank?
    url_string = "http://#{my_website.domain_name.to_s.downcase}"
    if my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:first] || my_website.domain_name == MyWebsiteForm::REIM_DOMAIN_NAME[:second]
      url_string = url_string + "/" + my_website.site.permalink_text
    end
      return url_string
  end
  
  def set_css_for_header_footer_in_temp2
    current_object_css=@investor_website.dynamic_css
    if current_object_css=="rgb(20, 149, 215)"
      return "#A10000"
    elsif current_object_css=="rgb(75, 183, 108)"
      return "#1E305E"
    elsif current_object_css=="rgb(190, 103, 60)"
      return "#007AA2"
    else ""
      return ""
    end
  end

  def return_about_us_text
    return truncate(@investor_website.about_us_page_text,300).to_s
  end
  
  def return_investor_image_path
    !@user.buyer_user_image.blank? ? ( !@user.buyer_user_image.find_mediumimg_thumbnail.blank? ? @user.buyer_user_image.public_filename(:mediumimg) : ( !@user.buyer_user_image.find_profile_thumbnail.blank? ? @user.buyer_user_image.public_filename(:profile) : "/images/buyer-60.jpg" )) : "/images/buyer-60.jpg"
  end

  def display_investor_page_text(page)
     case page
     when 'home'
       @investor_website.home_page_embed.to_s.strip.blank? ? @investor_website.home_page_text : @investor_website.home_page_embed
     when 'about'
       @investor_website.about_embed.to_s.strip.blank? ? @investor_website.about_us_page_text : @investor_website.about_embed
     when 'philosophy'
       @investor_website.philosophy_embed.to_s.strip.blank? ? @investor_website.our_philosophy_page_text : @investor_website.philosophy_embed
     when 'why_invest'
       @investor_website.why_invest_embed.to_s.strip.blank? ? @investor_website.why_invest_with_us_page_text : @investor_website.why_invest_embed
     end
  end
end