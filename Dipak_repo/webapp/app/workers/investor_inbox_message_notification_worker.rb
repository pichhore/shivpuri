class InvestorInboxMessageNotificationWorker
  @queue = :investor_inbox_message_notification
    def self.perform(user_id,investor_message_id,reciver_email, receiver_id)
      user = User.find_by_id (user_id)  
      investor_message = InvestorMessage.find_by_id(investor_message_id)
      UserNotifier.deliver_investor_message_notification(user,investor_message,reciver_email, receiver_id)
    end 
end
