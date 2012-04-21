class SendNotificationForNewBadgeWorker
  @queue = :send_notification_for_new_badge
    def self.perform(email,name,badge_name,image,subject,body,header,footer)
      UserNotifier.deliver_send_notification_for_new_badge(email,name,badge_name,image,subject,body,header,footer)
    end 
end
