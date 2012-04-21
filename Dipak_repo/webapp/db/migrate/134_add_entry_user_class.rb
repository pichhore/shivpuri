class AddEntryUserClass < ActiveRecord::Migration
  def self.up
    user_class = UserClass.new
    if UserClass.find_by_user_type("UC1").nil?
      user_class.user_type= "UC1"
      user_class.save
    end
  end

  def self.down
  end
end
