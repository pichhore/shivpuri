class SettingUserTypeOfUserOfBlankUserClass < ActiveRecord::Migration
  def self.up
    users = User.find(:all,:conditions=>["user_class_id is null"])
    logger=Logger.new("#{RAILS_ROOT}/log/user_list_of_blank_user_class.log")
    users.each do |user|
      user.update_attributes(:user_class_id=>1)
      logger.info " Class type changed to UC1 of  #{user.first_name}#{user.last_name}--#{user.email} "
    end
    
  end

  def self.down
  end
end
