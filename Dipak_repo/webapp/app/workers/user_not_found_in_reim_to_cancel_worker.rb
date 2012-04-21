class UserNotFoundInReimToCancelWorker
  @queue = :user_not_found_in_reim_when_cancel_his_subscription
    def self.perform(user_email, user_name, reason)
      UserNotifier.deliver_send_email_to_support_regarding_user_not_found_when_cancel(user_email, user_name, reason)
    end 
end