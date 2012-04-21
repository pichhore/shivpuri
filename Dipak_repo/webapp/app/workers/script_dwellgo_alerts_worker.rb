class ScriptDwellgoAlertsWorker
    @queue = :script_dwellgo_alerts_worker
    def self.perform
      system "#{RAILS_ROOT}/script/dwellgo/alerts.sh "
    end 
end
