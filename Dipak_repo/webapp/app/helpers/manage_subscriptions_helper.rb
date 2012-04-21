module ManageSubscriptionsHelper
  def check_subscription(retail_buyer,email_type)
    subscription_value = ""
    if email_type == RetailBuyerProfile::EMAIL_TYPE[:squeeze_trust_responder]
      subscription_value = retail_buyer.trust_responder_subscription
    elsif email_type == RetailBuyerProfile::EMAIL_TYPE[:retail_trust_responder]
      subscription_value = retail_buyer.trust_responder_subscription
    elsif email_type == RetailBuyerProfile::EMAIL_TYPE[:daily_notification]
      subscription_value = retail_buyer.daily_email_subscription
    elsif email_type == RetailBuyerProfile::EMAIL_TYPE[:weekly_notification]
      subscription_value = retail_buyer.weekly_email_subscription
    elsif email_type == RetailBuyerProfile::EMAIL_TYPE[:welcome_notification]
      subscription_value = retail_buyer.welcome_email_subscription
    end
    return subscription_value
  end
end
