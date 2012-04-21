class UserCancelInReimWorker
  @queue = :user_cancel_in_reim_queue
    def self.perform(user_id, user_name, reason)
      user = User.find_by_id (user_id)
      UserNotifier.deliver_send_email_to_support_regarding_cancel_user(user, user_name, reason)
    end 
end