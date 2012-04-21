class AddRetailBuyerPhoneToNotificationPhoneField < ActiveRecord::Migration
  def self.up
    logger = Logger.new("#{RAILS_ROOT}/log/notification_phone_field.log")
    begin
      retail_buyer_profiles = RetailBuyerProfile.find(:all)
      retail_buyer_profiles.each do |retail_buyer|
      profiles = ProfileFieldEngineIndex.find(:all, :conditions=>["profile_id=?", retail_buyer.profile_id])
        profiles.each do |profile|
          logger.info " before update === notification_phone : ( #{profile.notification_phone} ) , retail buyer phone : ( #{retail_buyer.phone} ) "
          profile.update_attributes(:notification_phone => retail_buyer.phone)
          profile.save
          logger.info " After update === notification_phone : ( #{profile.notification_phone} ) , retail buyer phone : ( #{retail_buyer.phone} ) "
          logger.info " /// *********************************/////////////////"
        end
      end
    rescue Exception=>exp
      logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      logger.info " /// *********************************/////////////////"
    end
  end

  def self.down
  end
end
