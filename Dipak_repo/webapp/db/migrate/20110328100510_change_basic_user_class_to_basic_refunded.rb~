class ChangeBasicUserClassToBasicRefunded < ActiveRecord::Migration
  def self.up
    user_class = UserClass.find(:first, :conditions => ["user_type=?", "BASIC"])
    if user_class.blank?
      user_class = UserClass.new
      user_class.user_type = "BASIC-REFUNDED"
      user_class.save
    else
      user_class.update_attributes(:user_type => "BASIC-REFUNDED")
    end
  end

  def self.down
  end
end
