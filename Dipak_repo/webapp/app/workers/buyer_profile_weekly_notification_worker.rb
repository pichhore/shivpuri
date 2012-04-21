class BuyerProfileWeeklyNotificationWorker
    @queue = :buyer_profile_weekly_notification
    def self.perform
      BuyerProfileNotification.send_weekly_notification_to_buyer(Date.today-6, Date.today)
    end 
end