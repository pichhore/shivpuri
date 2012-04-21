class ScriptDwellgoRefreshFeaturedProfilesWorker
    @queue = :script_dwellgo_refresh_featured_profiles_worker
    def self.perform
      system "#{RAILS_ROOT}/script/dwellgo/refresh_featured_profiles.sh "
    end 
end
