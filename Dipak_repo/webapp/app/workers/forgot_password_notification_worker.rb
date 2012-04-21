class ForgotPasswordNotificationWorker
  @queue = :forgot_password_notification
    def self.perform(user_id , url)
      user = User.find_by_id (user_id)
      hdr = UserNotifier.getsendgrid_header(user)
      UserNotifier.deliver_forgot_password(user, url, hdr.asJSON())
    end 
end