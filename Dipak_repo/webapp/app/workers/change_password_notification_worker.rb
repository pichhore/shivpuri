class ChangePasswordNotificationWorker
  @queue = :change_password_notification
    def self.perform(user_id , password)
      user = User.find_by_id (user_id)
      hdr = UserNotifier.getsendgrid_header(user)
      UserNotifier.deliver_change_password(user, password, hdr.asJSON())
    end 
end