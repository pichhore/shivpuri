class ProcessBuyerProfileNotificationWorker
    @queue = :process_buyer_profile_notification
    def self.perform(date1,limit,offset,date2=nil)
      BuyerProfileNotification.process_buyer_notification_batch(date1,limit,offset,date2)
    end 
end