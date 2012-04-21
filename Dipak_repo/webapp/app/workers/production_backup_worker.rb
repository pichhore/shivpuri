class ProductionBackupWorker
    @queue = :production_backup
    def self.perform
      system "/home/deploy/s3sync/s3backup.sh >> /tmp/production_backup.out"
    end 
end
