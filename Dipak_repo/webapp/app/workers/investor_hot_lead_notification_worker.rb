class InvestorHotLeadNotificationWorker
  @queue = :investor_hot_lead_notification
  def self.perform(user_id, seller_profile_id)
    seller_profile = SellerProfile.find(seller_profile_id)
    UserNotifier.deliver_investor_hot_lead_notification(User.find(user_id), seller_profile, seller_profile.seller_property_profile[0])
  end
end
