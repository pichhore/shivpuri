class ScriptDwellgoClicktaleTrackingWorker
    @queue = :script_dwellgo_clicktale_tracking_worker
    def self.perform
      system "#{RAILS_ROOT}/script/dwellgo/clicktale_tracking.sh"
    end 
end
