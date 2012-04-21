class InvestorMessageMarkedAsSpamNotificationWorker
  @queue = :investor_message_marked_as_spam_notification
    def self.perform(spam_claim_id, investor_message_id)
      spam_claim = SpamClaim.find_by_id(spam_claim_id)
      investor_message = InvestorMessage.find_by_id(investor_message_id)
      claim_by_investor = User.find(spam_claim.claim_id)
      UserNotifier.deliver_investor_message_marked_as_spam_notification(spam_claim, investor_message,claim_by_investor)
    end 
end