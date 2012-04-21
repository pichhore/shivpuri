class InvestorRequestNotificationWorker
  @queue = :investor_request_notification
    def self.perform(user_id , profile_display_name, name, phone, email, message, reason,buyer_website_link,new_format_url)
      params_hash = Hash.new()
      params_hash["name"] = name
      params_hash["phone"] = phone
      params_hash["email"] = email
      params_hash["message"] = message
      params_hash["reason"] = reason
      @request_information = InvestorRequestInformation.new()
      @request_information.from_hash(params_hash)
      user = User.find_by_id (user_id)
      UserNotifier.deliver_notify_investor_request(user, profile_display_name, @request_information,buyer_website_link,new_format_url) 
    end 
end
