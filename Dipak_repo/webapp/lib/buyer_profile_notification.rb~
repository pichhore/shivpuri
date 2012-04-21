class BuyerProfileNotification
  BATCH_SIZE = 100
  def self.send_message(date1,date2=nil)
    if date2.nil?
      buyer_profiles_size = Profile.find(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id and status='active' and is_owner=0 and notification_active=1 and notification_email!='' and notification_email is not null ",:order=>"created_at DESC", :group => "user_id,permalink").size
    else
      buyer_profiles_size = Profile.find(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id and status='active' and is_owner=0 and notification_active=1 and notification_email!='' and notification_email is not null", :order=>"created_at DESC", :group => "user_id, profile_id").size
    end
    
    i = (buyer_profiles_size.to_f/BATCH_SIZE).ceil
    (1..i).each do |index|
      #Resque code
      offset = BATCH_SIZE*(index-1) 
      Resque.enqueue(ProcessBuyerProfileNotificationWorker,date1,BATCH_SIZE,offset,date2)
    end    
  end
  
  def self.send_daily_notification_to_buyer(date1)
    send_message(date1) # Here We call the cron job at 12.05 AM
  end
  
  def self.send_weekly_notification_to_buyer(date1,date2) 
    send_message(date1,date2)
  end

 #Processing buyer notification emails in batches of records for opimization
  def self.process_buyer_notification_batch(date1,limit,offset,date2=nil)
    if date2.nil?
      self.send_daily(date1,limit,offset)
    else
      self.send_weekly(date1,limit,offset,date2)
    end
  end

  def self.send_daily(date1, limit, offset)
    daily_logger=Logger.new("#{RAILS_ROOT}/log/daily_buyer_notification.log")
    buyer_profiles = Profile.find(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id and status='active' and is_owner=0 and notification_active=1 and notification_email!='' and notification_email is not null " ,:include=>[{:user=>[:user_company_info,:buyer_notification,:user_company_image]}, :profile_fields,:retail_buyer_profile],:order=>"created_at DESC", :group => "user_id,permalink",:limit=>limit,:offset=>offset)
    matching_date = Date.parse( date1.gsub(/, */, '-') )
    
    buyer_profiles.each do |buyer_profile|
      begin
        if ( buyer_profile.retail_buyer_profile.blank? || ( !buyer_profile.retail_buyer_profile.blank? && buyer_profile.retail_buyer_profile.daily_email_subscription) )
          user = buyer_profile.user
          user_company_image = user.user_company_image
          if buyer_profile.is_buyer_both_type? || buyer_profile.is_buyer_wholesale_type?
            notifiyer_type = "wholesale_daily"
          else
            notifiyer_type = "daily"
          end
          
          buyer_notification = BuyerNotification.get_buyer_notification(user.id, notifiyer_type)
          property_profiles, count, total_pages = MatchingEngine.get_matches(:profile => buyer_profile, :created_date => matching_date)
          if buyer_profile.is_owner_finance_profile?
            near_property_profiles, near_count, near_total_pages = NearMatchingEngine.get_near_matches(:profile => buyer_profile, :created_date =>matching_date)
          else
            near_property_profiles, near_count, near_total_pages = [], 0, 0
          end

          user_company_info = user.user_company_info
          begin
            retail_buyer_name = buyer_profile.private_display_name
            email_intro, email_closing = BuyerProfileNotification.get_intro_and_closing(buyer_notification, retail_buyer_name, user)
            email_subject = buyer_notification.subject
            exact_near_match_count = count.to_i + near_count.to_i
            if exact_near_match_count > 0
              business_email = !user_company_info.blank? ? user_company_info.business_email : '<no-reply@reimatcher.com>'
              user_temp_email = user.email
              user.email = buyer_profile.display_notification_email
              hdr = UserNotifier.getsendgrid_header(user)
              profile_fields = buyer_profile.profile_fields
              buyer_profile.buyer_engagement_infos.create(:subject => email_subject, :description => "#{email_intro}"+"#{email_closing}", :note_type => "Email" )

              UserNotifier.deliver_send_buyer_daily_notification(user,property_profiles,near_property_profiles,date1,email_intro,email_closing,email_subject,user_company_image,business_email,buyer_profile,hdr.asJSON(), buyer_profile.display_notification_email, profile_fields)

              user.email = user_temp_email 
              if buyer_profile.is_owner_finance_profile?
                daily_logger.info "On #{matching_date} Daily Mail Sent To Owner Finance Buyer #{user.first_name} on #{buyer_profile.display_notification_email}  at #{Time.now}"
              else
                daily_logger.info "On #{matching_date} Daily Mail Sent To Wholesale Buyer #{user.first_name} on #{buyer_profile.display_notification_email}  at #{Time.now}"
              end									end
          rescue Exception=>exp
            #Taking action if any of user info fails
            BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"BuyerProfileNotification")
            daily_logger.info "Daily Notification Email could not be sent to  this Owner Finance  #{user.full_name} on date #{date1} exp #{exp} Buyer profile name: #{buyer_profile.private_display_name} Buyer notification email: #{buyer_profile.display_notification_email}"
          end
        end
      rescue Exception=>exp
        #Taking action if any of user info fails
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"BuyerProfileNotification")
        daily_logger.info "Daily Notification Email could not be sent to  this #{user.full_name} on date #{date1} exp #{exp} Buyer profile name: #{buyer_profile.private_display_name} Buyer notification email: #{buyer_profile.display_notification_email}"
      end
    end
  end

  def self.send_weekly(date1, limit, offset, date2)
    weekly_logger = Logger.new("#{RAILS_ROOT}/log/weekly_buyer_notification.log")
    buyer_profiles = Profile.find(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id and status='active' and is_owner=0 and notification_active=1 and notification_email!='' and notification_email is not null",:include=>[{:user=>[:user_company_info,:buyer_notification,:user_company_image]}, :profile_fields], :order => "created_at DESC", :group => "user_id, profile_id",:limit=>limit,:offset => offset)
    
    matching_date1 = Date.parse( date1.gsub(/, */, '-') )
    matching_date2 = Date.parse( date2.gsub(/, */, '-') )
    buyer_profiles.each do |buyer_profile|
      begin
        next unless buyer_profile.is_owner_finance_profile?
        if ( buyer_profile.retail_buyer_profile.blank? || ( !buyer_profile.retail_buyer_profile.blank? && buyer_profile.retail_buyer_profile.weekly_email_subscription) )
          user = buyer_profile.user
          user_company_image =user.user_company_image
          if buyer_profile.is_buyer_both_type? || buyer_profile.is_buyer_wholesale_type?
            notifiyer_type = "wholesale_weekly"
          else
            notifiyer_type = "weekly"
          end
          buyer_notification = BuyerNotification.get_buyer_notification(user.id, notifiyer_type)
          property_profiles, count, total_pages = MatchingEngine.get_matches(:profile => buyer_profile, :from_date => matching_date1, :to_date => matching_date2)

          if buyer_profile.is_owner_finance_profile?
            near_property_profiles, near_count, near_total_pages = NearMatchingEngine.get_near_matches(:profile => buyer_profile, :from_date => matching_date1, :to_date => matching_date2)
          else
            near_property_profiles, near_count, near_total_pages = [], 0, 0
          end
          
          user_company_info = user.user_company_info
          begin
            retail_buyer_name = buyer_profile.private_display_name
            email_intro, email_closing = BuyerProfileNotification.get_intro_and_closing(buyer_notification, retail_buyer_name, user)            
            email_subject = buyer_notification.subject
            business_email = !user_company_info.blank? ? user_company_info.business_email : '<no-reply@reimatcher.com>'
            user_temp_email = user.email
            user.email = buyer_profile.display_notification_email
            hdr = UserNotifier.getsendgrid_header(user)
            profile_fields = buyer_profile.profile_fields
            buyer_profile.buyer_engagement_infos.create(:subject => email_subject, :description => "#{email_intro}"+"#{email_closing}", :note_type => "Email" )
            UserNotifier.deliver_send_buyer_weekly_notification(user,property_profiles,near_property_profiles,date1,date2,email_intro,email_closing,email_subject,user_company_image,business_email,buyer_profile,hdr.asJSON(), profile_fields)
            if buyer_profile.is_owner_finance_profile?
              weekly_logger.info "Mail Sent To Owner Finance Buyer #{user.first_name} at #{Time.now} from #{business_email} #{user.id}"
            else
              weekly_logger.info "Mail Sent To Wholesale Buyer #{user.first_name} at #{Time.now} from #{business_email} #{user.id}"
            end
            user.email = user_temp_email
          rescue Exception => exp
            #Taking action if any of user info fails
            BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"BuyerProfileNotification")
            weekly_logger.info "Weekly Notification Email could not be sent to  this Owner Finance  #{user.full_name} on date #{date1} exp #{exp} Buyer profile name: #{buyer_profile.private_display_name} Buyer notification email: #{buyer_profile.display_notification_email}"
          end
        end
      rescue Exception=>exp
        #Taking action if any of user info fails
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"BuyerProfileNotification")
        weekly_logger.info "Weekly Notification Email could not be sent to  this #{user.full_name} on date #{date1} exp #{exp} Buyer profile name: #{buyer_profile.private_display_name} Buyer notification email: #{buyer_profile.display_notification_email}"
      end
    end
  end
  
  def self.set_user_notification(user,summary)
    buyer_notifications = user.buyer_notification
    buyer_notification =""
    buyer_notifications.each do |notification|
      if notification.user_id == user.id && notification.summary_type == summary
        buyer_notification = notification
        break
      end
    end
    return buyer_notification
  end

  def self.get_intro_and_closing(buyer_notification, retail_buyer_name, user)
    return fill_information(buyer_notification.email_intro.to_s, retail_buyer_name, user),
       fill_information(buyer_notification.email_closing.to_s, retail_buyer_name, user)
  end

  def self.fill_information(content, retail_buyer_name, user)
    user_company_info = user.user_company_info
    if user_company_info
      business_name = user_company_info.business_name
      business_address = user_company_info.full_address
      business_phone = user_company_info.business_phone
      business_email = user_company_info.business_email
    end
    business_email = '<no-reply@reimatcher.com>' if business_email.nil?
    content.gsub('{Business Name}',business_name.to_s).gsub('{Company name}',business_name.to_s).gsub('{Investor full name}',user.full_name).gsub('{Company phone}',business_phone.to_s).gsub('{Company address}',business_address.to_s).gsub('{Investor first name}',user.first_name).gsub('{Business Phone}',business_phone.to_s).gsub('{Business Address}',business_address.to_s).gsub('{Company email}',business_email).gsub('{Buyer first name}',retail_buyer_name.to_s)
  end
end
