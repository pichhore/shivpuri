class UserNotifier < ActionMailer::Base
  include UserNotifierHelper

  before_deliver do |mail|
    halt_callback_chain if bounced_address?(mail)
  end
  
  DEFAULT_URL = "http://www.reimatcher.com"
  APP_NAME = "reimatcher"
  SUPPORT_EMAIL = "REI Matcher <reimatcher@reimatcher.com>"
  STAGING_DEFAULT_EMAIL_BOX = "STAGING EMAILS <staging@reimatcher.com>"
  EMAIL_CATEGORIES = {:bmd => "Buyer Match Daily", :bmw => "Buyer Match Weekly", :bwe => "Buyer Welcome Email", :bts => "Buyer Trust Series", :bwc => "Buyer Website Contact", :bwq => "Buyer Website Question", :bwv => "Buyer Website View", :bwn => "Buyer Website New Buyer", :is => "Investor Summary", :im => "Investor Messaging", :pm => "Profile Messaging", :ssin => "Seller Site Investor Notification", :snl => "Seller New Lead", :sttr => "Seller Try to Reach", :sns => "Seller Next Steps", :snn => "Seller Not Now", :ae => "Activation", :ar => "Activation Reminder", :iwn => "Investor Website New Buyer" }

  default_url_options[:host] = 'stage.reimatcher.com' if RAILS_ENV == "staging"
  default_url_options[:host] = 'www.reimatcher.com' if RAILS_ENV == "production"
  default_url_options[:host] = 'localhost:3000' if RAILS_ENV == "development"
  default_url_options[:host] = 'test.local' if RAILS_ENV == "test"
  default_url_options[:host] = 'dev.reimatcher.com' if RAILS_ENV == "production_test"

  def signup_notification(user,header)
    setup_email(user)
    @subject    += 'Please activate your new account'
    profile_param = '/profile/' + user.profiles[0].id if user.profiles and user.profiles.first and user.profiles.first.owner?
    @body[:url]  = "#{default_url_options[:host]}/activate/#{user.activation_code}#{profile_param}"
    @headers["X-SMTPAPI"] = header
  end
  
   def welcome(email,first_name,login,activation_code,user_password,header)
    setup_welcome_email(email,first_name,login)
    @subject   = 'Welcome to REIMatcher!'
    @from = "REIMatcher <support@reimatcher.com>"
    @headers["X-SMTPAPI"] = header
    @body[:user_password] = user_password
    @body[:url]  = "#{REIMATCHER_URL}user_activate/#{activation_code}"
    @body[:env] = REIMATCHER_URL
    @content_type = "text/html"
    welcome_email_header = {:category => EMAIL_CATEGORIES[:ae]}
    @headers["X-SMTPAPI"] = welcome_email_header.to_json unless welcome_email_header.blank?
  end
  
  def new_user_welcome_email(user,subject,message)
    @from = "REIMatcher <no-reply@reimatcher.com>"
    @recipients = user.email
    @subject = "#{subject}"
    @sent_on = Time.now
    unless message.blank?
      @body = message.to_s.gsub("[User Email]",user.email.to_s).gsub("[User First Name]",user.first_name.to_s).gsub("[User Last Name]",user.last_name.to_s).gsub("[User Login]",user.login.to_s).gsub("[User Full Name]",user.first_name.to_s + " " + user.last_name.to_s).gsub("[User Activation Link]","#{REIMATCHER_URL}user_activate/#{user.activation_code}")
    else
      @body = ""
    end
    @content_type = "text/html"
    welcome_email_header = {:category => EMAIL_CATEGORIES[:ae]}
    @headers["X-SMTPAPI"] = welcome_email_header.to_json unless welcome_email_header.blank?
  end

  def activation(user,header)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = DEFAULT_URL
    @headers["X-SMTPAPI"] = header
  end

  def forgot_password(user, url,header)
    setup_email(user, user.login)

    #~ # Email header info
    @subject += "Forgotten password notification"
    @from = 'no-reply@reimatcher.com'

    #~ # Email body substitutions
    @body["name"] = "#{user.full_name}"
    @body["login"] = user.login
    @body["url"] = url || DEFAULT_URL
    @body["app_name"] = APP_NAME
    @headers["X-SMTPAPI"] = header
  end



  #~ def forgot_password (recipient, subject, message, header)
      #~ @subject = subject
      #~ @recipients = recipient
      #~ @from = 'no-reply@yourdomain.com'
      #~ @sent_on = Time.now
      #~ @body["title"] = 'This is title'
        #~ @body["email"] = 'sender@yourdomain.com'
         #~ @body["message"] = message
      #~ @headers["X-SMTPAPI"] = header
   #~ end
   
   
  def change_password(user, password, header)
    url=nil
    setup_email(user)

    # Email header info
    @subject += "Changed password notification"

    # Email body substitutions
    @body["name"] = "#{user.full_name}"
    @body["login"] = user.login
    @body["password"] = password
    @body["url"] = url || DEFAULT_URL
    @body["app_name"] = APP_NAME
    @headers["X-SMTPAPI"] = header
  end

  def feedback_submitted(feedback, header)
    setup_email(feedback)
    @recipients = SUPPORT_EMAIL

    @subject = "Feedback Submission from #{feedback.first_name} #{feedback.last_name}"
    @body["feedback"] = feedback
    @headers["X-SMTPAPI"] = header
  end

  def digest(*args)
    options      = args.last.is_a?(Hash) ? args.pop : {}
    @matches     = options[:new_matches] || { }
    @messages    = options[:new_messages] || { }
    @user        = options[:user]
    @interval    = options[:interval] || "daily"
    @date_string = options[:date_string] || ""
    @total_matches = 0
    @matches.each_pair { |profile_id, matches| @total_matches += matches.length }
    @total_messages = 0
    @messages.each_pair { |profile_id, messages| @total_messages += messages.length }
    @total_viewed = ProfileView.count( :all,
                                     :select => "DISTINCT viewed_by_profile_id",
                                     :conditions => [ "profile_id in (?)", @user.active_profiles.collect{ |profile| profile.id } ] )

    setup_email(@user)
    @subject += "#{@interval.capitalize} Summary for #{@date_string}"
    @change_frequency_link = url_for(:controller=>"account", :action=>"digest_frequency")

    @owner_profiles = @user.active_profiles.select {|p| p.owner?}
    @buyer_profiles = @user.active_profiles.select {|p| p.buyer?}
    is_hdr = {:category => EMAIL_CATEGORIES[:is]}
    @headers["X-SMTPAPI"] = is_hdr.to_json
    # handle html and plain formats
    content_type "multipart/alternative"

    part :content_type => "text/plain",
         :body => render_message("digest_plain",
                                 :owner_profiles=>@owner_profiles,
                                 :buyer_profiles=>@buyer_profiles,
                                 :matches=>@matches,
                                 :messages=>@messages,
                                 :user=>@user,
                                 :interval=>@interval,
                                 :date_string=>@date_string,
                                 :total_matches=>@total_matches,
                                 :total_viewed=>@total_viewed,
                                 :total_messages=>@total_messages,
                                 :change_frequency_link=>@change_frequency_link,
                                 :title=>@subject)

    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("digest_html",
                                 :owner_profiles=>@owner_profiles,
                                 :buyer_profiles=>@buyer_profiles,
                                 :matches=>@matches,
                                 :messages=>@messages,
                                 :user=>@user,
                                 :interval=>@interval,
                                 :date_string=>@date_string,
                                 :total_matches=>@total_matches,
                                 :total_viewed=>@total_viewed,
                                 :total_messages=>@total_messages,
                                 :change_frequency_link=>@change_frequency_link,
                                 :title=>@subject)
  end

  def invite(user, invitation, header)
    setup_email(invitation)
    @subject = "You have been invited to dwellgo"
    @body[:user]            = user
    @body[:invitation]      = invitation
    @body[:url]             = invitation_url(invitation)
    @headers["X-SMTPAPI"] = header
  end

  def notify_direct_message(profile_message_recipient)
    to_user = profile_message_recipient.to_profile.user
    setup_email(to_user)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "You have a personal message from a REIMatcher user"

    @change_frequency_link = url_for(:controller=>"account", :action=>"digest_frequency")
    @env = REIMATCHER_URL
    # 722 Sendgrid categorization
    pm_hdr = {:category => EMAIL_CATEGORIES[:pm]}
    @headers["X-SMTPAPI"] = pm_hdr.to_json
        
    # handle html and plain formats
    content_type "multipart/alternative"

    part :content_type => "text/plain",
         :body => render_message("notify_direct_message_plain",
                                 :profile_message_recipient=>profile_message_recipient,
                                 :to_profile=>profile_message_recipient.to_profile,
                                 :from_profile=>profile_message_recipient.from_profile,
                                 :change_frequency_link=>@change_frequency_link,:env=>@env)

    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("notify_direct_message_html",
                                 :profile_message_recipient=>profile_message_recipient,
                                 :to_profile=>profile_message_recipient.to_profile,
                                 :from_profile=>profile_message_recipient.from_profile,
                                 :change_frequency_link=>@change_frequency_link,:env=>@env)
  end

  def notify_buyer_created(investor_message_recipient, retail_buyer, retail_buyer_info, investor_url, url_parameter, permalink_text, new_format_url, city)
     setup_email(investor_message_recipient)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "New Buyer Lead: #{retail_buyer_info.first_name} #{retail_buyer_info.last_name}, #{retail_buyer_info.profile.investment_type.name}"
    bwn_hdr = {:category => EMAIL_CATEGORIES[:bwn]}
    @headers["X-SMTPAPI"] = bwn_hdr.to_json
    investor_first_name = investor_message_recipient.first_name
    content_type "multipart/alternative"
    part :content_type => "text/plain",
         :body => render_message("investor_buyer_created_plain",
                                                     :profile_retail_buyer=>retail_buyer, :retail_buyer_info=>retail_buyer_info, :investor_first_name=>investor_first_name, :investor_url=>investor_url, :url_parameter=>url_parameter, :permalink_text=>permalink_text, :new_format_url => new_format_url, :city => city)
    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("investor_buyer_created_html",
                                                     :profile_retail_buyer=>retail_buyer, :retail_buyer_info=>retail_buyer_info, :investor_first_name=>investor_first_name, :investor_url=>investor_url, :url_parameter=>url_parameter, :permalink_text=>permalink_text, :new_format_url => new_format_url, :city => city)
  end
  
  def notify_buyer_created_from_investor_website(user, field,  retail_buyer, investor_url )
    setup_email(user)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "New Buyer Lead: #{retail_buyer.first_name} #{retail_buyer.last_name}, #{retail_buyer.profile.investment_type.name}"
    bwn_hdr = {:category => EMAIL_CATEGORIES[:iwn]}
    @headers["X-SMTPAPI"] = bwn_hdr.to_json
    investor_first_name = user.first_name
    content_type "multipart/alternative"
    part :content_type => "text/plain",
         :body => render_message("investor_buyer_created_from_investor_website_plain",
                                                     :profile_retail_buyer=>field, :retail_buyer_info=>retail_buyer, :investor_first_name=>investor_first_name, :investor_url=>investor_url, :user => user)
    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("investor_buyer_created_from_investor_website_html",
                                                     :profile_retail_buyer=>field, :retail_buyer_info=>retail_buyer, :investor_first_name=>investor_first_name, :investor_url=>investor_url, :user => user)
  end

  def notify_investor_contact(investor_message_recipient, investor_contact_us, investor_territory, investor_id, new_format_url)
     setup_email(investor_message_recipient)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "User Wishes to Be Contacted"
    bwc_hdr = {:category => EMAIL_CATEGORIES[:bwc]}
    @headers["X-SMTPAPI"] = bwc_hdr.to_json
    content_type "multipart/alternative"
    part :content_type => "text/plain",
         :body => render_message("investor_message_recipient_plain",
                                                     :profile_message_recipient=>investor_contact_us, :investor_territory => investor_territory, :investor_id => investor_id, :new_format_url => new_format_url)
    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("investor_message_recipient_html",
                                                     :profile_message_recipient=>investor_contact_us, :investor_territory => investor_territory, :investor_id => investor_id, :new_format_url => new_format_url)

  end

  def notify_investor_from_investor_website(investor_message_recipient, investor_contact_us, investor_website_id)
    setup_email(investor_message_recipient)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "User Wishes to Be Contacted"
    bwc_hdr = {:category => EMAIL_CATEGORIES[:bwc]}
    @headers["X-SMTPAPI"] = bwc_hdr.to_json
    content_type "multipart/alternative"
    part :content_type => "text/plain",
         :body => render_message("investor_message_recipient_plain_from_iw",
                                                     :profile_message_recipient=>investor_contact_us, :investor_website_id => investor_website_id)
    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("investor_message_recipient_html_from_iw",
                                                     :profile_message_recipient=>investor_contact_us, :investor_website_id => investor_website_id)

  end


  def notify_investor_request(investor_message_recipient, property_address, request_information,buyer_website_link,new_format_url)
     setup_email(investor_message_recipient)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "Request More Info - [#{property_address.split(",")[0]}]"
    unless request_information.blank?
    if request_information.reason == "0"
      ir_hdr = {:category => EMAIL_CATEGORIES[:bwv]}
    else
      ir_hdr = {:category => EMAIL_CATEGORIES[:bwq]}
    end
    @headers["X-SMTPAPI"] = ir_hdr.to_json
    end
    content_type "multipart/alternative"
    part :content_type => "text/plain",
         :body => render_message("investor_request_plain",
                                                     :request_information_message=>request_information,:buyer_website_link=>buyer_website_link, :show_property_address=>property_address.split(",")[0], :new_format_url => new_format_url)
    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("investor_request_html",
                                                     :request_information_message=>request_information,:buyer_website_link=>buyer_website_link, :show_property_address=>property_address.split(",")[0], :new_format_url => new_format_url)
  end

  def referral_contest_invite(from_name, from_email, to_name, to_email)
    # since we are not using any user account details, have to do the setup manually
    @recipients  = (RAILS_ENV == "staging") ? STAGING_DEFAULT_EMAIL_BOX : "#{to_email}"
    # dev testing only
    # @recipients  = "javajames@gmail.com" if RAILS_ENV == "development"
    @from        = SUPPORT_EMAIL
    @subject     = "[#{APP_NAME}] You have been invited to Dwellgo"
    @sent_on     = Time.now

    # handle html and plain formats
    content_type "multipart/alternative"

    part :content_type => "text/plain",
         :body => render_message("referral_contest_invite_plain",
                                 :from_name  => from_name,
                                 :from_email => from_email,
                                 :to_name    => to_name,
                                 :to_email   => to_email)

    part :content_type => "text/html",
         :transfer_encoding => 'base64',
         :body => render_message("referral_contest_invite_html",
                                 :from_name  => from_name,
                                 :from_email => from_email,
                                 :to_name    => to_name,
                                 :to_email   => to_email)
  end

  def profile_marked_as_spam_notification(spam_claim, profile)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Admin<admin@reimatcher.com>"
    @subject     = "[#{APP_NAME}] Profile marked as spam"
    @sent_on     = Time.now
    @body[:spam_claim] = spam_claim
    @body[:profile] = profile
  end

  def profile_message_marked_as_spam_notification(spam_claim, profile_message)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Admin<admin@reimatcher.com>"
    @subject     = "[#{APP_NAME}] Profile Message marked as spam"
    @sent_on     = Time.now
    @body[:spam_claim] = spam_claim
    @body[:profile_message] = profile_message
    @body[:from_profile] = profile_message.profile_message_recipients.first.from_profile if profile_message.profile_message_recipients.first
  end
    
  def investor_message_marked_as_spam_notification(spam_claim, investor_message,claim_by_investor)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Admin<admin@reimatcher.com>"
    @subject     = "[REIMatcher] Message Marked as SPAM"
    @sent_on     = Time.now
    @body[:spam_claim] = spam_claim
    @body[:investor_message] = investor_message
    @body[:from_user] = claim_by_investor
    @content_type="text/html"
  end
  
  def property_about_to_expire(user, subject, body)
    @from = "REIMatcher Property About To Expiration<noreply@reimatcher.com>"
    @recipients = user
    @subject = "[#{APP_NAME}] #{subject}"
    @sent_on = Time.now
    @body = body
    @user = user 
  end
  
  def property_expired(recipient_email, recipient_first_name, subject, message, profile_link,address,zip_code,zipcode,header)
    state = zipcode.nil? ? "" : zipcode.state
    city = zipcode.nil? ? "" : zipcode.city
    @from = "REIMatcher <no-reply@reimatcher.com>"
    @recipients = recipient_email
    @subject = "#{subject}"
    @sent_on = Time.now
    unless message.blank?
      !profile_link.blank? ? message1 = message.to_s.gsub("[Property Profile Link]",profile_link) : message1 = message.to_s.gsub("[Property Profile Link]","")
      !address.blank? ? message2 = message1.to_s.gsub("[Property Profile Address]",address) : message2 = message1.to_s.gsub("[Property Profile Address]","")
      !zip_code.blank? ? message3 = message2.to_s.gsub("[Zip Code]",zip_code) : message3 = message2.to_s.gsub("[Zip Code]","")
      !state.blank? ? message4 = message3.to_s.gsub("[State]",state) : message4 = message3.to_s.gsub("[State]","") 
      !city.blank? ? message5 = message4.to_s.gsub("[City]",city) : message5 = message4.to_s.gsub("[City]","") 
      @body = message5.to_s
    else
      @body = ""
    end
    @content_type = "text/html"
    @headers["X-SMTPAPI"] = header
  end
  
  def buyer_expired(recipient_email, recipient_first_name, subject, message, profile_link,name,zip_code_string,retail_buyer_profile,pfei_data,profile_fields_data,header)
    @from = "REIMatcher <no-reply@reimatcher.com>"
    @recipients = recipient_email
    @subject = "#{subject}"
    @sent_on = Time.now
    unless message.blank?
      !profile_link.blank? ? message1 = message.to_s.gsub("[Buyer Profile Link]",profile_link) : message1 = message.to_s.gsub("[Buyer Profile Link]","")
      !name.blank? ? message2 = message1.to_s.gsub("[Buyer Profile Name]",name) : message2 = message1.to_s.gsub("[Buyer Profile Name]","")
      !zip_code_string.empty? ? message3 = message2.to_s.gsub("[Zip Code]",zip_code_string) : message3 = message2.to_s.gsub("[Zip Code]","")
      if !retail_buyer_profile.blank?
        rb_phone = retail_buyer_profile.phone
        rb_email = retail_buyer_profile.email_address
      else
        rb_phone = !profile_fields_data.blank? ? profile_field_values(profile_fields_data, "notification_phone") : nil
        rb_email = !profile_fields_data.blank? ? profile_field_values(profile_fields_data, "notification_email") : nil
        rb_phone.is_a?(Array) ? rb_phone = nil : rb_phone = rb_phone
        rb_email.is_a?(Array) ? rb_email = nil : rb_email = rb_email
      end
      !rb_phone.blank? ? message4 = message3.to_s.gsub("[Retail Buyer Phone Number]",rb_phone) : message4 = message3.to_s.gsub("[Retail Buyer Phone Number]","")
      !rb_email.blank? ? message5 =  message4.to_s.gsub("[Retail Buyer Email Address]",rb_email) : message5 = message4.to_s.gsub("[Retail Buyer Email Address]","")
      if !profile_fields_data.blank?
        beds = profile_field_values(profile_fields_data, "beds")
        baths = profile_field_values(profile_fields_data, "baths")
        max_mon_pay = profile_field_values(profile_fields_data, "max_mon_pay")
        max_down_pay = profile_field_values(profile_fields_data, "max_dow_pay")
        sqft_max = profile_field_values(profile_fields_data, "square_feet_max")
        sqft_min = profile_field_values(profile_fields_data, "square_feet_min")
      end
      if !beds.blank?
        message6 =  message5.to_s.gsub("[Number Beds]",beds) 
      else
        message6 = message5.to_s.gsub("[Number Beds]","")
      end
      if !baths.blank?
        message7 =  message6.to_s.gsub("[Number Baths]",baths) 
      else
        message7 = message6.to_s.gsub("[Number Baths]","")
      end
      !max_down_pay.blank? ? message8 = message7.to_s.gsub("[Maximum Down Payment]",max_down_pay.to_s) : message8 = message7.to_s.gsub("[Maximum Down Payment]","")
      !max_mon_pay.blank? ? message9 = message8.to_s.gsub("[Maximum Monthly Payment]",max_mon_pay.to_s) : message9 = message8.to_s.gsub("[Maximum Monthly Payment]","")
      (!sqft_max.blank? && !sqft_min.blank?) ? message10 = message9.to_s.gsub("[Sqft Range]","#{sqft_min.to_s}-#{sqft_max.to_s}") : message10 = message9.to_s.gsub("[Sqft Range]","")
      @body = message10.to_s
    else
      @body = ""
    end
    @content_type = "text/html"
    @headers["X-SMTPAPI"] = header
  end
  
  # welcome reminder email to newly registered user 
  def user_welcome_reminder(user,subject,message)
    @from = "REIMatcher <no-reply@reimatcher.com>"
    @recipients = user.email
    @subject = "#{subject}"
    @sent_on = Time.now
    user_activation_link = "#{REIMATCHER_URL}user_activate/#{user.activation_code}"
    unless message.blank?
      @body = message.to_s.gsub("[User Email]",user.email.to_s).gsub("[User First Name]",user.first_name.to_s).gsub("[User Last Name]",user.last_name.to_s).gsub("[User Login]","<a href='#{user.login.to_s}'>#{user.login.to_s}</a>").gsub("[User Full Name]",user.first_name.to_s + " " + user.last_name.to_s).gsub("[User Activation Link]","<a href='#{user_activation_link}'>#{user_activation_link}</a>")
    else
      @body = ""
    end
    @content_type = "text/html"
    reminder_welcome_email_header = {:category => EMAIL_CATEGORIES[:ar]}
    @headers["X-SMTPAPI"] = reminder_welcome_email_header.to_json unless reminder_welcome_email_header.blank?
#      @headers["X-SMTPAPI"] = header
  end

  def send_buyer_daily_notification(user,property_profiles,near_property_profiles,date1,email_intro,email_closing,email_subject,user_company_image,business_email,buyer_profile,header , recipient, profile_fields )
    @from = "#{user.full_name } <#{business_email}>"
    @recipients = recipient
    @subject = email_subject
    @sent_on = Time.now
    @body = body  
    @body[:buyer_profile] = buyer_profile
    @body[:user] = user    
    @body[:owner_profiles] = property_profiles
    @body[:near_owner_profiles] = near_property_profiles
    @body[:email_intro]=email_intro
    @body[:email_closing]=email_closing
    @body[:user_company_image] = user_company_image
    @body[:profile_fields] = profile_fields
    @content_type = "text/html"
    header["initial"] = EMAIL_CATEGORIES[:bmd] unless header.blank?
    @headers["X-SMTPAPI"] = header
  end

  def send_wholesale_buyer_daily_notification(user,property_profiles,near_property_profiles,date1,email_intro,email_subject,user_company_image,business_email,buyer_profile,header , recipient, profile_fields )
    @from = "#{user.full_name } <#{business_email}>"
    @recipients = recipient
    @subject = email_subject
    @sent_on = Time.now
    @body = body  
    @body[:buyer_profile] = buyer_profile
    @body[:user] = user    
    @body[:owner_profiles] = property_profiles
    @body[:near_owner_profiles] = near_property_profiles
    @body[:email_intro]=email_intro
    @body[:user_company_image] = user_company_image
    @body[:profile_fields] = profile_fields
    @content_type = "text/html"
    header["initial"] = EMAIL_CATEGORIES[:bmd] unless header.blank?
    @headers["X-SMTPAPI"] = header
  end
  
  def send_buyer_weekly_notification(user,property_profiles,near_property_profiles,date1,date2,email_intro,email_closing,email_subject,user_company_image,business_email,buyer_profile,header, profile_fields)
    @from = "#{user.full_name } <#{business_email}>"
    @recipients = user.email
    @subject = email_subject
    @sent_on = Time.now
    @body = body  
    @body[:buyer_profile] = buyer_profile
    @body[:user] = user
    @body[:owner_profiles] = property_profiles
    @body[:near_owner_profiles] = near_property_profiles
    @body[:email_intro]=email_intro
    @body[:email_closing]=email_closing
    @body[:user_company_image] = user_company_image
    @body[:profile_fields] = profile_fields
    @content_type = "text/html"
    header["initial"] = EMAIL_CATEGORIES[:bmw] unless header.blank?
    @headers["X-SMTPAPI"] = header
  end

  def send_wholesale_buyer_weekly_notification(user,property_profiles,near_property_profiles,date1,date2,email_intro,email_subject,user_company_image,business_email,buyer_profile,header, profile_fields)
    @from = "#{user.full_name } <#{business_email}>"
    @recipients = user.email
    @subject = email_subject
    @sent_on = Time.now
    @body = body  
    @body[:buyer_profile] = buyer_profile
    @body[:user] = user
    @body[:owner_profiles] = property_profiles
    @body[:near_owner_profiles] = near_property_profiles
    @body[:email_intro]=email_intro
    @body[:user_company_image] = user_company_image
    @body[:profile_fields] = profile_fields
    @content_type = "text/html"
    header["initial"] = EMAIL_CATEGORIES[:bmw] unless header.blank?
    @headers["X-SMTPAPI"] = header
  end

  def send_retail_buyer_welcome_notification(fields_value, notification, user, profile)
    @from = "#{user.full_name } <#{user.email}>"
    @recipients = fields_value
    @subject = notification.subject
    @sent_on = Time.now
    @body = body
    @body[:user] = user
    @body[:current_user] = user
    @body[:email_intro] = notification.email_intro
    @body[:email_closing] = notification.email_closing
    @body[:user_company_image] = user.user_company_image
    @body[:retail_buyer_name] = profile.private_display_name
    @body[:url_parameter] = profile.url_parameter
    @body[:permalink_text] = profile.permalink_text
    @body[:profile_id] = profile.id
    @body[:new_format_url] = profile.new_format_url
    @content_type = "text/html"
    bwe_hdr = {:category => EMAIL_CATEGORIES[:bwe]}
    @headers["X-SMTPAPI"] = bwe_hdr.to_json
  end

  def send_retail_wholesale_buyer_welcome_notification(fields_value, notification_subject,notification_email_intro, user, profile_private_display_name, profile_url_parameter, profile_permalink_text,profile_id, profile_new_format_url)
    @from = "#{user.full_name } <#{user.email}>"
    @recipients = fields_value
    @subject = notification_subject
    @sent_on = Time.now
    @body = body  
    @body[:user] = user    
    @body[:current_user] = user    
    @body[:email_intro]= notification_email_intro
    @body[:user_company_image] = user.user_company_image
    @body[:retail_buyer_name] = profile_private_display_name
    @body[:url_parameter] = profile_url_parameter
    @body[:permalink_text] = profile_permalink_text
    @body[:profile_id] = profile_id
    @body[:new_format_url] = profile_new_format_url
    @content_type = "text/html"
    bwe_hdr = {:category => EMAIL_CATEGORIES[:bwe]}
    @headers["X-SMTPAPI"] = bwe_hdr.to_json
  end


  #Trust Responder Email of Seven steps
  def trust_responder_notification(buyer_first_name,buyer_email,buyer_mail_number,investor,trust_responder_notification,buyer_id,is_squeeze_buyer)
    @from = "#{investor.full_name } <#{investor.investor_email_address}>"
    @recipients = buyer_email
    @subject = "#{trust_responder_notification.email_subject}"
    @sent_on = Time.now
    @body[:buyer_first_name] = buyer_first_name
    @body[:buyer_mail_number] = buyer_mail_number
    @body[:email_body] = trust_responder_notification.email_body
    @body[:investor] = investor
    @body[:buyer_id] = buyer_id
    @body[:is_squeeze_buyer] = is_squeeze_buyer
    @content_type = "text/html"
    bts_hdr = {:category => EMAIL_CATEGORIES[:bts]}
    @headers["X-SMTPAPI"] = bts_hdr.to_json
  end

  def send_error_notification args
    email = "404error@reimatcher.com" if args[:textEmail].blank? || args[:textEmail] == 'Email'
    @from = email || args[:textEmail]
    @recipients = "support@reimatcher.com" if RAILS_ENV == "production"
    @recipients = "qasystech2@systematixtechnocrates.com" if RAILS_ENV == "staging" || RAILS_ENV == "development" || RAILS_ENV == "test" || RAILS_ENV == "production_test"
    @subject = "404 Error - User Comment"
    @sent_on = Time.now
    @body = body  
    @body[:email_intro] = "Hi, <br>The following error occurred: <br><br>"
    @body[:email_text] = args[:text]
    @body[:current_path] = args[:current_path]
    @body[:user_info] = args[:user_info]
    @body[:email_closing] = "<br><br>404 Error Notifier, <br> REIMatcher"
    @content_type = "text/html"
  end

#Sending message from investor to investor
  def investor_message_notification(investor,message,recipient_email, receiver_id)
    @from = "REIMatcher <#{receiver_id}.#{message.id}@dev.reimatcher.com>"
    @recipients = recipient_email
    @subject = "[REIMBridge] - #{message.subject}"
    @sent_on = Time.now
    @body[:env] = REIMATCHER_URL
    @body[:message] = message
    @body[:investor] = investor
    @content_type = "text/html"
    im_hdr = {:category => EMAIL_CATEGORIES[:im]}
    @headers["X-SMTPAPI"] = im_hdr.to_json
  end

  def send_seller_responder_sequence_notification(notification_email, seller_profile, seller_property_profile)
    @seller_profile = seller_profile
    @seller_property_profile = seller_property_profile
    @investor = @seller_profile.user
    @from = "#{@investor.full_name} < #{(( @investor.user_company_info.blank?) or ( @investor.user_company_info.business_email.blank? )) ? "#{@investor.email}" : "#{@investor.user_company_info.business_email}"} > "
    @recipients = @seller_profile.email
    @subject = notification_email.email_subject
    @notification_email_body = notification_email.email_body
    @content_type = "text/html"
    seq_name = seller_profile.seller_property_profile[0].responder_sequence_assign_to_seller_profile.seller_responder_sequence.sequence_name
      seller_responder_header = {:category => EMAIL_CATEGORIES[:snl]} if seq_name == "sequence_one"
      seller_responder_header = {:category => EMAIL_CATEGORIES[:sttr]} if seq_name == "sequence_two"
      seller_responder_header = {:category => EMAIL_CATEGORIES[:sns]} if seq_name == "sequence_three"
      seller_responder_header = {:category => EMAIL_CATEGORIES[:snn]} if seq_name == "sequence_four"
      @headers["X-SMTPAPI"] = seller_responder_header.to_json unless seller_responder_header.blank?
  end

  def send_mis_match_user_notification(user_name, user_email, product_name, purchase_date)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Support<support@reimatcher.com>"
    @subject = "Mis-matched Email on Purchase"
    @body[:user_name] = user_name
    @body[:user_email] = user_email
    @body[:product_name] = product_name
    @body[:purchase_date] = purchase_date
    @content_type = "text/html"
  end

  def send_match_lah_sc_user_notification(user_name, user_email, product_name, purchase_date)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Support<support@reimatcher.com>"
    @subject = "Matched Email on Purchase from LAH 1Shopping Cart"
    @body[:user_name] = user_name
    @body[:user_email] = user_email
    @body[:product_name] = product_name
    @body[:purchase_date] = purchase_date
    @content_type = "text/html"
  end

  def second_email_for_new_user(user)
    setup_email(user)
    @subject   = 'Welcome to REIMatcher!'
    @from = "REIMatcher <support@reimatcher.com>"
    @body[:url]  = "#{REIMATCHER_URL}user_activate/#{user.activation_code}"
    @body[:env] = REIMATCHER_URL
    @content_type = "text/html"
  end

  def send_lah_shopping_cart_mis_match_user(first_name, last_name, user_email, product_name, product_id, purchase_date)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Support<support@reimatcher.com>"
    @subject = "Mis Matched Email on Purchase from LAH 1Shopping Cart"
    @body[:first_name] = first_name
    @body[:last_name] = last_name
    @body[:user_email] = user_email
    @body[:product_id] = product_id
    @body[:product_name] = product_name
    @body[:purchase_date] = purchase_date
    @content_type = "text/html"
  end

  def send_matched_shopping_cart_user_purchase_other_product(user_name, user_email, product_name, purchase_date, product_id, customer_id)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Support<support@reimatcher.com>"
    @subject = "Matched Shopping Cart User Purchased Other Product"
    @body[:User_name] = user_name
    @body[:user_email] = user_email
    @body[:product_id] = product_id
    @body[:product_name] = product_name
    @body[:purchase_date] = purchase_date
    @body[:customer_id] = customer_id
    @content_type = "text/html"
  end

  def send_email_to_support_regarding_cancel_user(user, user_name, reason)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Support<brittney@loveamericanhomes.com>" if RAILS_ENV == "production"
    @recipients = "qasystech2@systematixtechnocrates.com" if RAILS_ENV == "staging" || RAILS_ENV == "development" || RAILS_ENV == "test" || RAILS_ENV == "production_test"
    @subject = "The following user #{user.login} has canceled their reimatcher subscription"
    @body[:user] = user
    @body[:user_name] = user_name
    @body[:reason] = reason
    @content_type = "text/html"
  end

  def send_email_to_support_regarding_user_not_found_when_cancel(user_email, user_name, reason)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Support<qasystech2@systematixtechnocrates.com>"
    @subject = "User not found in REIMatcher when cancel his subscription"
    @body[:user_email] = user_email
    @body[:user_name] = user_name
    @body[:reason] = reason
    @content_type = "text/html"
  end

  def send_mismatched_failed_shopping_cart_user(user_email, order_id)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "REIMatcher Support<support@reimatcher.com>"
    @subject = "Mis-Matched Failed Shopping Cart User"
    @body[:user_email] = user_email
    @body[:order_id] = order_id
    @content_type = "text/html"
  end

  def send_email_to_failed_user_when_login_second_time(user)
    @from       = "REIMatcher Alerts<system@reimatcher.com>"
    @recipients = "#{user.full_name}<#{user.email}>"
    @subject = "Payment Failed for REIMatcher"
    @body[:user] = user
    @content_type = "text/html"
  end

  def investor_cold_lead_notification(investor, seller_profile, seller_property)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "New AMPS Cold Lead: #{seller_profile.first_name}, #{seller_property.zip_code}"
    @recipients = investor.email
    @body[:investor] = investor
    @body[:seller_profile] = seller_profile
    @body[:seller_property_profile] = seller_property
    @content_type = "text/html"
    ssin_hdr = {:category => EMAIL_CATEGORIES[:ssin]}
    @headers["X-SMTPAPI"] = ssin_hdr.to_json
  end

  def investor_hot_lead_notification(investor, seller_profile, seller_property)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "New AMPS Hot Lead: #{seller_profile.first_name}, #{seller_property.property_address}, #{seller_property.zip_code}"
    @recipients = investor.email
    @body[:investor] = investor
    @body[:seller_profile] = seller_profile
    @body[:seller_property_profile] = seller_property
    @content_type = "text/html"
    ssin_hdr = {:category => EMAIL_CATEGORIES[:ssin]}
    @headers["X-SMTPAPI"] = ssin_hdr.to_json
  end

  def send_investor_notification_new_seller_lead(user, seller_profile, seller_property)
    @from = "REIMatcher <noreply@reimatcher.com>"
    city = get_city_by_zipcode(seller_property.zip_code)
    seller_property_address = seller_property.property_address.blank? ? "" : (", " + seller_property.property_address) 
    @subject = "New Seller Lead: #{seller_profile.first_name}#{seller_property_address}#{city}"
    @recipients = user.email
    @body[:investor] = user
    @body[:seller_profile] = seller_profile
    @body[:seller_property_profile] = seller_property
    @content_type = "text/html"
    ssin_hdr = {:category => EMAIL_CATEGORIES[:ssin]}
    @headers["X-SMTPAPI"] = ssin_hdr.to_json
  end

  def send_investor_notification_new_comment(user, name,sender_email,comment,seller_website)
    @from = "#{name} <#{sender_email}>"
    @subject = "Real Estate Agent Left a Comment For You..."
    @recipients = user.email
    @body[:investor] = user
    @body[:name] = name
    @body[:email] = sender_email
    @body[:seller_website] = seller_website
    @body[:comment] = comment
    @content_type = "text/html"
  end

  def send_property_contract_to_out_of_reim(emails, contract)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = "Property contract"
    @recipients = emails
    @content_type = "text/html"
    if FileTest.exists?( "#{RAILS_ROOT}/tmp/"+contract.to_s)
      attachment :content_type => "application/pdf",
                         :filename => contract.split(" ")[0],
                         :body => File.read( "#{RAILS_ROOT}/tmp/"+contract.to_s)
    end
  end

  def send_notification_for_new_badge(email,name,badge_name,image,subject,body,header,footer)
    @from = "REIMatcher <noreply@reimatcher.com>"
    @subject = subject
    @recipients = email
    @body[:body] = body
    @body[:header] = header
    @body[:footer] = footer
    @body[:name] = name
    @body[:badge_name] = badge_name
    @body[:image] = image
    @content_type = "text/html"
  end


  # def amps_magnet_responder_report count, report
    # @from = "REIMatcher <noreply@reimatcher.com>"
    # @subject = "AMPS Responders Report"
    # @recipients = ""
    # @body[:report] = report
    # @body[:count] = count
    # @body[:done_at] = Time.now
    # @content_type = "text/html"
  # end


  def send_support_email(to_email, subject, body, from_email, user_first_name, user_last_name)
    @from = "#{user_first_name} #{user_last_name} <#{from_email}>"
    @subject = subject
    @recipients = to_email
    @body[:body] = body
#     @content_type = "text/html"
  end


  def self.bounced_address?(mail)
    address = mail['to'].to_s
    BouncedEmail.find_by_email(address).nil? ? false : true
  end
  

  protected
  
  def setup_email(user, email = nil)
    # force when in staging mode to allow Damon to view all outbound emails without spamming real user accounts
    @recipients = email.blank? ? "#{user.email}" : email
    @from        = SUPPORT_EMAIL
    @subject     = "[#{APP_NAME}] "
    @sent_on     = Time.now
    @body[:user] = user
  end
  
  def setup_welcome_email(email,first_name,login)
    # force when in staging mode to allow Damon to view all outbound emails without spamming real user accounts
    @recipients  = "#{email}"
    @from        = SUPPORT_EMAIL
    @subject     = "[#{APP_NAME}] "
    @sent_on     = Time.now
    @body[:login] = login
    @body[:first_name] = first_name
  end
  
  
  def self.getsendgrid_header(user)
    hdr = SmtpApiHeader.new
    receiver = [user.email]
    # Another subsitution variable
    names = [user.first_name]
    
    # Set all of the above variables
    hdr.addTo(receiver)
    hdr.addSubVal('-name-', names)
    
    # Specify that this is an initial contact message
    hdr.setCategory("initial")
    
    # Enable a text footer and set it
    hdr.addFilterSetting('footer', 'enable', 1)
    hdr.addFilterSetting('footer', "text/plain", "Thank you for your business")
    return hdr
  end
  
  def self.getsendgrid_welcome_header(email,first_name)
    hdr = SmtpApiHeader.new
    receiver = [email]
    # Another subsitution variable
    names = [first_name]
    
    # Set all of the above variables
    hdr.addTo(receiver)
    hdr.addSubVal('-name-', names)
    
    # Specify that this is an initial contact message
    hdr.setCategory("initial")
        
    # Enable a text footer and set it
    hdr.addFilterSetting('footer', 'enable', 1)
    hdr.addFilterSetting('footer', "text/plain", "Thank you for your business")
    return hdr
  end
  
  def get_city_by_zipcode(zip)
    unless zip.blank?
      zip_hash = Zip.find(:first, :conditions => ["zip=?",zip])
      city = zip_hash.blank? ? "" : (", " + zip_hash.city.to_s)
    else
      city = ""
    end
    return city
  end
end
  