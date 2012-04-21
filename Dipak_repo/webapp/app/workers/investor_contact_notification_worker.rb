class InvestorContactNotificationWorker
  @queue = :investor_contact_notification
    def self.perform(user_id , name, email, phone, message, investor_territory, investor_id, new_format_url)
      @investor_contact_us = InvestorContactUs.new
      contact_us_hash = Hash.new()
      contact_us_hash["name"] = name
      contact_us_hash["email"] = email
      contact_us_hash["phone"] = phone
      contact_us_hash["message"] = message
      @investor_contact_us.from_hash(contact_us_hash)
      user = User.find_by_id (user_id)
      UserNotifier.deliver_notify_investor_contact(user, @investor_contact_us, investor_territory, investor_id, new_format_url)
    end 
end
