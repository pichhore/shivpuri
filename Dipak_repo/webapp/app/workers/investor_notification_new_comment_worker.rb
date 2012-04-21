class InvestorNotificationNewCommentWorker
  @queue = :investor_noti_new_comment
    def self.perform(website_id, name,sender_email,comment)
      seller_website = SellerWebsite.find_by_id(website_id)
      investor = seller_website.user
      UserNotifier.deliver_send_investor_notification_new_comment(investor, name,sender_email,comment, seller_website)
    end 
end