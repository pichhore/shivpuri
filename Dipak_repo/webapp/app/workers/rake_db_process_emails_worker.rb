class RakeDbProcessEmailsWorker
    @queue = :rake_db_process_emails
    def self.perform
      system "cd #{RAILS_ROOT} && RAILS_ENV=#{RAILS_ENV} /usr/bin/rake  db:process_emails "
    end 
end
