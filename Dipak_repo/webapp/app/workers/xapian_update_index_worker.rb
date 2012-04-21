class XapianUpdateIndexWorker
    @queue = :xapian_update_index
    def self.perform()
      system "cd #{RAILS_ROOT} && RAILS_ENV=#{RAILS_ENV} rake xapian:update_index models='Profile User SellerProfile SellerPropertyProfile RetailBuyerProfile ProfileFieldEngineIndex'"
    end
end
