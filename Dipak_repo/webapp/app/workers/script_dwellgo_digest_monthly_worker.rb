class ScriptDwellgoDigestMonthlyWorker
    @queue = :script_dwellgo_digest_monthly_worker
    def self.perform
      system "#{RAILS_ROOT}/script/dwellgo/digest_monthly.sh "
    end 
end
