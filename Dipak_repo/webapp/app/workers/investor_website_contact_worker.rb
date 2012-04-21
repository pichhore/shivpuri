class InvestorWebsiteContactWorker
  @queue = :investor_website_contact
    def self.perform(user_id , name, email, phone, message, investor_website_id)
      @investor_contact_us = InvestorContactUs.new
      contact_us_hash = Hash.new()
      contact_us_hash["name"] = name
      contact_us_hash["email"] = email
      contact_us_hash["phone"] = phone
      contact_us_hash["message"] = message
      @investor_contact_us.from_hash(contact_us_hash)
      user = User.find_by_id (user_id)
      UserNotifier.deliver_notify_investor_from_investor_website(user, @investor_contact_us, investor_website_id)
    end 
end
