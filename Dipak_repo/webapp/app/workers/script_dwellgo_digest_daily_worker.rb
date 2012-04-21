class ScriptDwellgoDigestDailyWorker
    @queue = :script_dwellgo_digest_daily_worker
    def self.perform
      system "#{RAILS_ROOT}/script/dwellgo/digest_daily.sh "
    end 
end
