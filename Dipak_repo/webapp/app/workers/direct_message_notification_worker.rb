class DirectMessageNotificationWorker
  @queue = :direct_message_notification
    def self.perform(profile_message_recipient_id)
      pmr = ProfileMessageRecipient.find_by_id (profile_message_recipient_id)
      UserNotifier.deliver_notify_direct_message(pmr)
    end 
end