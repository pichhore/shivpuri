# this class observes profile changes and rebuilds a de-normalized version of the associated key-value pairs
require 'permalink'

class ProfileObserver < ActiveRecord::Observer

  def after_create(profile)
    send_buyer_welcome_notification(profile) if profile.buyer?
    user = User.find(profile.user_id)
    #Award a Badge to user when created a profile
    BadgeUser.reward_badge_for_the_user(user)
    activity_id = profile.buyer? ? Feed::BUYER_ADDED : Feed::PROPERTY_ADDED
    territory_id = get_territory(profile.zip_code, profile.country)
    Feed.add(profile.user_id, territory_id, activity_id)
  end
  
  def after_save(profile)
    unless profile.profile_need_help_flag
      ProfileFieldEngineIndex.refresh_index_for(profile)
      if !profile.skip_matches_update
        pmc = ProfileMatchesCount.find_by_profile_id(profile.id)
        pmc.destroy if !pmc.blank?
        ProfileMatchesCount.create(:profile_id => profile.id, :count => -1)
        Resque.enqueue(CacheMatchingDataWorker)
      end
    end
  end

  def after_destroy(profile)
    profile.delete_with_cascade
  end
  
  def get_territory(zip,country)
    unless zip.blank?
      @zips = Zip.find_by_zip(zip.split(",").first)
      return @zips.territory_id if !@zips.nil?
    end
  end

  def send_buyer_welcome_notification profile
    if profile.is_buyer_both_type? || profile.is_buyer_wholesale_type?
      notifiyer_type = "wholesale_welcome"
    else
      notifiyer_type = "welcome"
    end
    
    buyer_email = ProfileField.find_by_profile_id_and_key(profile.id, "notification_email")
    if buyer_email.nil?
      buyer_email = ProfileFieldEngineIndex.find_by_profile_id(profile.id).notification_email
    end

    if buyer_email && !buyer_email.value.blank?
      user = User.find(profile.user_id)
      user_company_info = user.user_company_info
      business_email = !user_company_info.blank? ? user_company_info.business_email : '<no-reply@reimatcher.com>'
      user.email = profile.display_notification_email
      user_temp_email = user.email
      hdr = UserNotifier.getsendgrid_header(user)

      retail_buyer_name = profile.private_display_name
      buyer_notification = BuyerNotification.get_buyer_notification(profile.user_id, notifiyer_type)
      email_intro, email_closing = BuyerProfileNotification.get_intro_and_closing(buyer_notification, retail_buyer_name, user)
      email_subject = buyer_notification.subject
      profile.buyer_engagement_infos.create(:subject => email_subject, :description => "#{email_intro}"+"#{email_closing}", :note_type => "Email" )
         
      begin
        UserNotifier.deliver_send_retail_buyer_welcome_notification(buyer_email.value, buyer_notification, user, profile)
        # Removed resque since its causing issues. Need to debug & re-enable soon        
        # Resque.enqueue(SendRetailBuyerWelcomeNotificationWorker, buyer_email.value, notification, user, profile)
      rescue Exception => exp
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"OwnerFinanceBuyerProfileWelcomeNotification")
        daily_logger = Logger.new("#{RAILS_ROOT}/log/daily_buyer_notification.log")
        daily_logger.info "Welcome Notification Email could not be sent to  this Owner Finance  #{user.full_name} on date #{Time.now} exp #{exp}"
      end
    end
  end
  
end


