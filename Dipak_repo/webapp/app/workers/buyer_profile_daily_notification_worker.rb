class BuyerProfileDailyNotificationWorker
    @queue = :buyer_profile_daily_notification
    def self.perform
      BuyerProfileNotification.send_daily_notification_to_buyer(Date.today-1)
    end 
end