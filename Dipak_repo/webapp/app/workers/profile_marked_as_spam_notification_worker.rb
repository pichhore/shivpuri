class ProfileMarkedAsSpamNotificationWorker
  @queue = :profile_marked_as_spam_notification
    def self.perform(spam_claim_id, profile_id)
      spam_claim = SpamClaim.find_by_id (spam_claim_id)
      profile = Profile.find_by_id (profile_id)
      UserNotifier.deliver_profile_marked_as_spam_notification(spam_claim, profile)
    end 
end