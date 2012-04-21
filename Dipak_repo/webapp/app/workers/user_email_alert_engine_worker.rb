class UserEmailAlertEngineWorker
    @queue = :user_email_alert_engine
    def self.perform
       UserEmailAlertEngine.process()
    end 
end