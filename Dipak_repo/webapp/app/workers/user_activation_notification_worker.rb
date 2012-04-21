class UserActivationNotificationWorker
  @queue = :user_activation_notification
    def self.perform(user_id )
      user = User.find_by_id (user_id)
      hdr = UserNotifier.getsendgrid_header(user)
      UserNotifier.deliver_activation(user, hdr.asJSON())
    end 
end