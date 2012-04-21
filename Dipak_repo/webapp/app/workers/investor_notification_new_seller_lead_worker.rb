class InvestorNotificationNewSellerLeadWorker
  @queue = :investor_noti_new_seller_lead
    def self.perform(seller_property_id, user_id)
      seller_property = SellerPropertyProfile.find_by_id(seller_property_id)
      seller_profile = seller_property.seller_profile
      user = User.find_by_id(user_id)
      UserNotifier.deliver_send_investor_notification_new_seller_lead(user, seller_profile, seller_property)
    end 
end