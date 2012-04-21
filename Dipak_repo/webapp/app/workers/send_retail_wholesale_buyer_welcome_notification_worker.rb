class SendRetailWholesaleBuyerWelcomeNotificationWorker
  @queue = :send_retail_wholesale_buyer_welcome_notification
    def self.perform(pro_value,notification_subject, notification_email_intro, user_id, profile_private_display_name, profile_url_parameter, profile_permalink_text,profile_id, profile_new_format_url)
      user = User.find_by_id (user_id)
      UserNotifier.deliver_send_retail_wholesale_buyer_welcome_notification(pro_value,notification_subject, notification_email_intro, user, profile_private_display_name, profile_url_parameter, profile_permalink_text,profile_id, profile_new_format_url)
     end 
end
