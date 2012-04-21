class ReferralContestInviteNotificationWorker
  @queue = :referral_contest_notification
    def self.perform(from_name, from_email, to_name, to_email)
      UserNotifier.deliver_referral_contest_invite(from_name, from_email, to_name, to_email)
    end 
end