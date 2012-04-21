class CacheMatchingDataWorker

  @queue = :cache_matching_data
    def self.perform()
      logger = logger || Logger.new("#{RAILS_ROOT}/log/cache_matching_data_worker.log")
      logger.info("I have started running")
      CacheEngine.populate_cache()

    end 
end
