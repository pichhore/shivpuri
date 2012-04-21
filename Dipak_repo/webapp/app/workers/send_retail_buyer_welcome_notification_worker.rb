class SendRetailBuyerWelcomeNotificationWorker
  @queue = :send_retail_buyer_welcome_notification

  def self.perform(buyer_email, notification, user, profile)
    UserNotifier.deliver_send_retail_buyer_welcome_notification(buyer_email, notification, user, profile)
  end 
end
