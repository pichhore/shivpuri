class SendEmailToFailedUserWhenLoginSecondTimeWorker
  @queue = :send_email_to_failed_user_when_login_second_time
    def self.perform(user_id)
      user = User.find_by_id(user_id)
      UserNotifier.deliver_send_email_to_failed_user_when_login_second_time(user)
    end 
end