module AccountHelper
  
  def display_title(summary_type)
    if !session[:summary_type].blank?
      case session[:summary_type]
        when "daily"
          'Buyer Responder (Daily)'
        when "weekly"
          'Buyer Responder (Summary)'
        when "welcome"
          'Welcome Email'
        when "trust_resp_series"
          'Buyer Trust Responder Series'
      end
    else
      case summary_type
        when "daily"
          'Buyer Responder (Daily)'
        when "weekly"
          'Buyer Responder (Summary)'
        when "welcome"
          'Welcome Email'
        when "trust_resp_series"
          'Buyer Trust Responder Series'
        else
          'Welcome Email'
      end
    end
  end

  def display_page_title_for_change_delete_reason
    return (@deleted_profile.buyer? or @deleted_profile.buyer_agent?) ? "Deleted Buyer - #{@deleted_profile.private_display_name}" : "Deleted Property - #{@deleted_profile.name}"
  end
  
  def display_email_intro(email_intro)
    return display_email_assign_values(email_intro).gsub("{Company name}","#{!current_user.user_company_info.blank? ? current_user.user_company_info.business_name : '{Company name}'}")
  end
  
  def display_email_closing(email_closing)
    if !current_user.user_company_info.blank?
	business_name = !current_user.user_company_info.business_name.blank?  ? current_user.user_company_info.business_name : '{Company name}'
	business_address = !current_user.user_company_info.business_address.blank?  ? current_user.user_company_info.business_address : '{Company address}'
	business_phone = !current_user.user_company_info.business_phone.blank?  ? current_user.user_company_info.business_phone : '{Company phone}'
    else
	business_name = '{Company name}'
	business_address = '{Company address}'
	business_phone = '{Company phone}'
    end
    return display_email_assign_values(email_closing).gsub("{Company name}",business_name).gsub("{Company address}",business_address).gsub("{Company phone}",business_phone).gsub('{Business Phone}',business_phone).gsub('{Business Address}',business_address).gsub('{Business Name}',business_name)
  end
  
  def display_email_assign_values(text)
    {"{Investor first name}"=> "first_name", "{Investor full name}" => "full_name",
      "{Company name}" => "user_company_info.business_name",
      "{Company address}" => "user_company_info.business_address",
      "{Company phone}" => "user_company_info.business_phone",
      "{eBook Download Link}" => "",
      "{Company email}"=>"user_company_info.business_email"}.each_pair do |k, v|
      if k ==  "{Company address}"
        if !current_user.user_company_info.blank?
          value = current_user.user_company_info.business_address + "<br>" + current_user.user_company_info.city  + ",\n" + current_user.user_company_info.state  + ",\n" + current_user.user_company_info.zipcode
        else
          value = k
        end
      elsif k == "{eBook Download Link}"
        value = "http://budurl.com/OwnerFinanceGuidev1"
      else
        value = !current_user.user_company_info.blank? ? eval("current_user."+v) : k
      end
      text = text.gsub(k, value)
    end
   # "{Company address}" = "{Company city}" + "{Company add}",
    retail_buyer = current_user.profiles.first ? current_user.profiles.first.retail_buyer_profile : nil
    text.gsub("{Retail buyer first name}", (!current_user.user_company_info.blank? && retail_buyer) ? retail_buyer.first_name : "{Retail buyer first name}")
  end
  
  def assign_subject
    if !session[:subject].blank?
      subject = session[:subject]
    elsif !@buyer_notification.subject.nil?
      subject = @buyer_notification.subject
    else
      case params[:id]
        when "daily": subject = "I found some homes that match your needs"
        when "weekly": subject = "Here's a weekly Summary of Homes that match your needs"
        when "welcome": subject = "Here's your Free Owner Finance Buyer's Guide!"
        else subject = "Here's your Free Owner Finance Buyer's Guide!"
      end
    end
  end
  
  def assign_email_intro
    if !session[:email_intro].blank?
      email_intro = session[:email_intro]
    elsif !@buyer_notification.email_intro.nil?
      email_intro = @buyer_notification.email_intro.gsub("{Business Name}","{Company name}").gsub("{Business Address}","{Company address}").gsub("{Business Phone}","{Company phone}")
    else
      case params[:id]
        when "daily":
          email_intro = "Hi, this is {Investor full name} with {Company name},
                         <p>Once a day I search for properties that match the criteria you entered into your profile on my website. I only send an email if I find something. Today, I found one or more that match your available down payment and monthly payment, and the area(s) you specified that you are interested in.  Check it out below...</p>"
        when "weekly":
          email_intro= "Once a week, I send an email with the homes I've come across that match your criteria.  You'll get an email from me every Thursday with the current homes that match your payment criteria, location, and amenities."
        when "welcome":
          email_intro= "<p>Hey {Retail buyer first name},</p>

<p>I want to personally thank you for taking the first step to finding your next Dream Home through Owner Financing!</p>

<p>If you haven't downloaded it yet, below is a link to your Free Owner Finance Buyer's Guide...<br />
 <a href='http://budurl.com/OwnerFinanceGuidev1'>http://budurl.com/OwnerFinanceGuidev1</a>
</p>
<p>Hopefully, you completed a Buyer Profile for yourself, which will enable us to notify you of homes that match your location and buying criteria.</p>

<p>If you haven't yet created a Buyer Profile, just return here and click the Orange button!</p>

{buyer website HP}

<p>I'll also be sending you some important tips on things to watch out for when buying through Owner Financing...so stay tuned! </p>"
        else
          email_intro= "<p>Hey {Retail buyer first name},</p>

<p>I want to personally thank you for taking the first step to finding your next Dream Home through Owner Financing!</p>

<p>If you haven't downloaded it yet, below is a link to your Free Owner Finance Buyer's Guide...<br />
 <a href='http://budurl.com/OwnerFinanceGuidev1'>http://budurl.com/OwnerFinanceGuidev1</a>
</p>
<p>Hopefully, you completed a Buyer Profile for yourself, which will enable us to notify you of homes that match your location and buying criteria.</p>

<p>If you haven't yet created a Buyer Profile, just return here and click the Orange button!</p>

{buyer website HP}

<p>I'll also be sending you some important tips on things to watch out for when buying through Owner Financing...so stay tuned! </p>"
      end
    end
  end
  
  def assign_email_closing
    if !session[:email_closing].blank?
      email_closing = session[:email_closing]
    elsif !@buyer_notification.email_closing.nil?
      email_closing = @buyer_notification.email_closing.gsub("{Business Name}","{Company name}").gsub("{Business Address}","{Company address}").gsub("{Business Phone}","{Company phone}")
    else
      case params[:id]
        when "daily":
          email_closing = "If any of these properties look interesting to you, give me a call at {Company phone} so that we can talk further and I can arrange to possibly show it to you.
                          <p>Thanks,</p
                          <p>{Investor full name}</p>
                          {Company name}<br />
                          {Company address}<br />
                          {Company phone}"
        when "weekly":
          email_closing = "Let me know if you see a property that you would like to take a look at.  I look forward to hearing back from you.
                          <p>Thanks,</p
                          <p>{Investor full name}</p>
                          {Company name}<br />
                          {Company address}<br />
                          {Company phone}"
        when "welcome":
          email_closing = "<p>Remember, we're here to serve you!</p>

{Investor full name}<br />

{Company name}<br />

{Company address}<br />

{Company phone}<br />

{Company email}<br /><br />

P.S. Again, here is the link to create your own personal Buyer Profile, if you haven't already done it!<br />
{buyer website HP}"

        else
          email_closing = "<p>Remember, we're here to serve you!</p>

{Investor full name}<br />

{Company name}<br />

{Company address}<br />

{Company phone}<br />

{Company email}<br /><br />

P.S. Again, here is the link to create your own personal Buyer Profile, if you haven't already done it!<br />
{buyer website HP}"
      end
    end
  end
  
  def assign_class(id, summary_type, summary)
    if !summary_type.nil?
      if summary_type == summary
        return 'clicked'
      else
        return 'summary'
      end
    end
    if summary == 'welcome'
      unless (id == summary || summary_type == summary|| (id.nil? && summary_type.nil?))
        return summary
      else
        return 'clicked'
      end
    else
      unless (id == summary || summary_type == summary)
        return summary
      else
        return 'clicked'
      end
    end
  end

  def message_user_name(user_id)
    user = User.find_by_id(user_id)
    return user.full_name
  end

  def no_of_investor_message(subject,user,sender)
    inbox_content = []
    messages = InvestorMessage.find_by_sql(["select * from (select im.id as id,im.body as body,im.subject as subject,im.sender_id as sender_id,imr.reciever_id as reciever_id ,im.created_at as created_at from investor_messages as im,investor_message_recipients as imr where imr.investor_message_id = im.id and subject =?) as imj where (sender_id =? and reciever_id=?) or (reciever_id =? and sender_id=?) order by created_at desc",subject, sender, user, sender , user])
    body = truncate(messages[0].body,50)
    inbox_content = [messages.size,body]

    return inbox_content
  end

  def display_profile_name(profile_message_id)
    profile_info = ProfileMessageRecipient.find(:all,:conditions=>["profile_message_id=?",profile_message_id])
    if profile_info.size >0
      if profile_info[0].from_profile.user.id == current_user.id
          return profile_info[0].to_profile 
      else
          return profile_info[0].from_profile 
      end
    else
      return nil
    end
  end

  def get_profile_ids(profile_message_id)
      profile_info = ProfileMessageRecipient.find(:all,:conditions=>["profile_message_id=?",profile_message_id])
      profile_info.each do |pro_info|
        return_to_profile = pro_info.to_profile
        return_from_profile = pro_info.from_profile
        if return_to_profile.user_id == current_user.id || return_from_profile.user_id == current_user.id
          return return_to_profile , return_from_profile
          break
        end
      end
      return nil, nil
  end


  def display_feeds(feed)
    if feed.activity_id == 1
      return "<a href='#' onclick=\"go_to_back_page('/account/investor_full_page/#{feed.user_id}');\"> #{feed.user.first_name.humanize}</a> added <font style='font-weight: normal;'>a New Buyer Profile in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 2
      return "<a href='#' onclick=\"go_to_back_page('/account/investor_full_page/#{feed.user_id}');\"> #{feed.user.first_name.humanize}</a> added <font style='font-weight: normal;'>a home for sale in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 3
      return "<a href='#' onclick=\"go_to_back_page('/account/investor_full_page/#{feed.user_id}');\"> #{feed.user.first_name.humanize}</a> sold <font style='font-weight: normal;'>a property in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 4
      return "<a href='#' onclick=\"go_to_back_page('/account/investor_full_page/#{feed.user_id}');\"> #{feed.user.first_name.humanize}</a> bought <font style='font-weight: normal;'>a property in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 5
      return "<a href='#' onclick=\"go_to_back_page('/account/investor_full_page/#{feed.user_id}');\"> #{feed.user.first_name.humanize}</a> is talking with <font style='font-weight: normal;'>a Seller in </font>#{feed.territory.reim_name.humanize}"
    end
  end

  def current_message_in_profile(subject,to_profile_id)
     profile_message = ProfileMessage.find_by_sql(["select * from profile_messages where id in (select profile_message_id from (select * from profile_message_recipients where profile_message_id in (select id from profile_messages where subject=? or subject=?) and (to_profile_id=? or from_profile_id=?)) as pm where (pm.to_profile_id in (select id from profiles where user_id=?) or pm.from_profile_id in (select id from profiles where user_id=?))) order by created_at desc limit 1",subject.to_s.gsub('Re: ',''),'Re: '+subject.to_s.gsub('Re: ',''),to_profile_id,to_profile_id,current_user.id,current_user.id])
    
    if profile_message.size>0
      profile_message_recipients = profile_message[0].profile_message_recipients.find(:all,:conditions=>["to_profile_id =? or from_profile_id=?",to_profile_id,to_profile_id])
      viewd_at = nil
      if profile_message_recipients.size>0
        viewd_at = profile_message_recipients[0].from_profile.user_id != current_user.id && profile_message_recipients[0].to_profile.user_id == current_user.id ? profile_message_recipients[0].viewed_at : 'notnil'
        #viewd_at = profile_message_recipients[0].viewed_at
        return  profile_message[0].body,viewd_at,profile_message_recipients[0].id
      else
        return  nil,nil,nil
      end
    else
      return nil, nil,nil
    end
  end
  
  def profiles_count(profiles, type=nil)
    count = 0
    profiles.each do |pro|
      if !type.nil?
        count = count + 1 if pro.profile_type.name == type && pro.deleted_at == nil && pro.status
      else
        @profile_views = ProfileView.find_all_by_profile_id(pro.id)
        count = count + @profile_views.length if !@profile_views.nil?
      end
    end
    return count
  end

  def profiles_viewed_count(user)
    return ProfileView.find_by_sql("select * from profile_views as pv,profiles as p where pv.viewed_by_profile_id=p.id and p.user_id = '#{user.id}';").count
  end
  
  def deals_completed(user)
     profiles = Profile.find_by_sql("SELECT * FROM `profiles`   WHERE (user_id = '#{user.id}' ) AND profile_delete_reason_id is not null AND profile_delete_reason_id not in ('other_buyer','other_owner')")
    return profiles.length
  end

  def deleted_property_counts(user)
     profiles = Profile.find_by_sql("SELECT * FROM `profiles`   WHERE (user_id = '#{user.id}' ) AND profile_delete_reason_id is not null")
    return profiles.length
  end
  
  def display_territories(user_territories)
    terror = ""
    user_territories.each do |user_territory|
      terror = terror + user_territory.territory.reim_name.humanize + ", "
    end
    return terror.chomp(", ")
  end
  
  def show_badges(investor)
    # user_badges = BadgeUser.find_all_by_user_id(user_id)
    temp = ""
    investor.badge_users.each do |user_badge|
      badge_name = user_badge.badge.name
      badge_image_path = !user_badge.badge.blank? ? ( !user_badge.badge.badge_image.blank? ? ( !user_badge.badge.badge_image.find_small_thumbnail.blank? ? "<img style='margin-left:5px; margin-right:5px;' src='#{user_badge.badge.badge_image.public_filename(:small)}' title='#{badge_name}'>" : ( "<img style='width:35px; margin-left:5px; margin-right:5px;' src='#{user_badge.badge.badge_image.public_filename}' title='#{badge_name}'>" )) : "" ) : ""
      
      temp = temp + badge_image_path if !badge_image_path.blank?
    end
    return temp
  end

  def get_time(membership_time, created_at)
    time_span ="#{membership_time}.month"
    time = created_at + eval(time_span)
    if time <= Time.now
      return true
    else
      return false
    end
  end

  def display_investor_feeds(feed)
    if feed.activity_id == 1
      return "<a href='/account/investor_full_page/#{feed.user_id}?state_code=#{@state_selected}&user_territory_id=#{@territory_selected}&search_investor=#{@search_investor}&page_number=#{@page_number.to_s}'> #{feed.user.first_name.humanize}</a> added <font style='font-weight: normal;'>a New Buyer Profile in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 2
      return "<a href='/account/investor_full_page/#{feed.user_id}?state_code=#{@state_selected}&user_territory_id=#{@territory_selected}&search_investor=#{@search_investor}&page_number=#{@page_number.to_s}'> #{feed.user.first_name.humanize}</a> added <font style='font-weight: normal;'>a home for sale in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 3
      return "<a href='/account/investor_full_page/#{feed.user_id}?state_code=#{@state_selected}&user_territory_id=#{@territory_selected}&search_investor=#{@search_investor}&page_number=#{@page_number.to_s}'> #{feed.user.first_name.humanize}</a> sold <font style='font-weight: normal;'>a property in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 4
      return "<a href='/account/investor_full_page/#{feed.user_id}?state_code=#{@state_selected}&user_territory_id=#{@territory_selected}&search_investor=#{@search_investor}&page_number=#{@page_number.to_s}'> #{feed.user.first_name.humanize}</a> bought <font style='font-weight: normal;'>a property in</font>  #{feed.territory.reim_name.humanize}"
    end
    if feed.activity_id == 5
      return "<a href='/account/investor_full_page/#{feed.user_id}?state_code=#{@state_selected}&user_territory_id=#{@territory_selected}&search_investor=#{@search_investor}&page_number=#{@page_number.to_s}'> #{feed.user.first_name.humanize}</a> is talking with <font style='font-weight: normal;'>a Seller in</font>  #{feed.territory.reim_name.humanize}"
    end
  end

  def is_having_products?
    if !@alert.alert_definition.blank? and !@user.map_lah_product_with_user.blank?
    if (@alert.alert_definition.amps == true and @user.map_lah_product_with_user.amps == false)
      return true
    elsif (@alert.alert_definition.amps_gold == true and @user.map_lah_product_with_user.amps_gold == false)
      return true
    elsif (@alert.alert_definition.re_volution == true and @user.map_lah_product_with_user.re_volution == false)
      return true
    elsif (@alert.alert_definition.top1 == true and @user.map_lah_product_with_user.top1 == false)
      return true
    elsif (@alert.alert_definition.rei_mkt_dept == true and @user.map_lah_product_with_user.rei_mkt_dept == false)
      return true
    else
      return false
    end
    else
      return false
    end
  end
  
  def get_syndication_site_icon(site_name)
    if File.exists?("#{RAILS_ROOT}/public/images/syndication_site_logos/#{site_name}.png")
      return "<img src=\"/images/syndication_site_logos/#{site_name}.png\" alt=#{site_name} width=93 height=24 >"
    else
      return site_name
    end
  end
end

