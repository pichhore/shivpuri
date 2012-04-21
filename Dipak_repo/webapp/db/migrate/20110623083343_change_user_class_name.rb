class ChangeUserClassName < ActiveRecord::Migration
  def self.up
    user_classes=UserClass.find(:all)
    user_classes.each do |user_class|
      if user_class.user_type == "UC1"
        user_class.update_attributes(:user_type_name=>"Plus")
      elsif user_class.user_type == "UC2"
        user_class.update_attributes(:user_type_name=>"Pro")
      end
    end
  end

  def self.down
  end
end
