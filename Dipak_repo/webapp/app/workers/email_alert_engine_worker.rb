class EmailAlertEngineWorker
    @queue = :email_alert_engine
    def self.perform
      EmailAlertEngine.process()
    end 
end