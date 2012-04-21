class BuyerCreatedFromInvestorWebsiteNotificationWorker
  @queue = :buyer_created_from_investor_website_notification
    def self.perform(user_id , field, retail_buyer_id, investor_url)
      user = User.find_by_id (user_id)
      retail_buyer = RetailBuyerProfile.find_by_id (retail_buyer_id)
      UserNotifier.deliver_notify_buyer_created_from_investor_website(user, field,  retail_buyer, investor_url )
    end 
end
