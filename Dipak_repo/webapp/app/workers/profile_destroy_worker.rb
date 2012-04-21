class ProfileDestroyWorker
    @queue = :profile_destroy
    def self.perform
      Profile.destroy_profile_by_cron()
    end 
end