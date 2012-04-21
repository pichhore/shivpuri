class CacheEngine

  @@logger = Logger.new("#{RAILS_ROOT}/log/cache_matching_data.log")
  def self.populate_cache()
    begin
      logger  =  @@logger

      logger.info "\n"
      pmc = ProfileMatchesCount.find(:all, :conditions => {:status => false}, :limit => 50)
      
      if !pmc.nil? && !pmc.empty?
        #CacheEngine.offset = CacheEngine.offset + 50
        pmc.each do |p|
          profile = Profile.find_by_id(p.profile_id)
          ProfileMatchesDetail.save_profile_matches_data(profile) unless profile.nil?
          logger.info "profile_id #{p.profile_id} completed "
        end
      else
        logger.info "Caching completed"
      end
    rescue Exception=>exp
      #Taking action if something goes wrong
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"CacheEngine")
      logger.info "Something went wrong exp #{exp}"
    end
  end
end
