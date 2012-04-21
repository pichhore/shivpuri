class BuyerCreatedNotificationWorker
  @queue = :buyer_created_notification
    def self.perform(user_id , field, retail_buyer_id, investor_url, url_parameter, permalink_text, new_format_url, city)
      user = User.find_by_id (user_id)
      retail_buyer = RetailBuyerProfile.find_by_id (retail_buyer_id)
      UserNotifier.deliver_notify_buyer_created(user, field,  retail_buyer, investor_url, url_parameter, permalink_text, new_format_url, city )
    end 
end
