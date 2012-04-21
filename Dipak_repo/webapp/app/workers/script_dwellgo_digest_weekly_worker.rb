class ScriptDwellgoDigestWeeklyWorker
    @queue = :script_dwellgo_digest_weekly_worker
    def self.perform
      system "#{RAILS_ROOT}/script/dwellgo/digest_weekly.sh "
    end 
end
