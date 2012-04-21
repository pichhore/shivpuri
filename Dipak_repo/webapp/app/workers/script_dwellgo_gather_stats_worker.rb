class ScriptDwellgoGatherStatsWorker
    @queue = :script_dwellgo_gather_stats_worker
    def self.perform
      system "#{RAILS_ROOT}/script/dwellgo/gather_stats.sh "
    end 
end
