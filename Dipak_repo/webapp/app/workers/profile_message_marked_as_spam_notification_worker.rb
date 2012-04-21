class ProfileMessageMarkedAsSpamNotificationWorker
  @queue = :profile_message_marked_as_spam_notification
    def self.perform(spam_claim_id, profile_message_id)
      spam_claim = SpamClaim.find_by_id (spam_claim_id)
      profile_message = ProfileMessage.find_by_id (profile_message_id)
      UserNotifier.deliver_profile_message_marked_as_spam_notification(spam_claim, profile_message)
    end 
end