class RakeDbProcessUserEmailsWorker
    @queue = :rake_db_process_user_emails
    def self.perform
       EmailAlertToUser.process_user_emails
    end 
end
