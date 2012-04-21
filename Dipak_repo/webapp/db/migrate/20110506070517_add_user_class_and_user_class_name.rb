class AddUserClassAndUserClassName < ActiveRecord::Migration
  def self.up
    user_classes=UserClass.find(:all)
    user_classes.each do |user_class|
      if user_class.user_type == "UC1"
        user_class.update_attributes(:user_type_name=>"Basic")
      elsif user_class.user_type == "UC2"
        user_class.update_attributes(:user_type_name=>"Plus")
      elsif user_class.user_type == "BASIC-REFUNDED"
        user_class.update_attributes(:user_type_name=>"Free-Trial",:user_type=>"UC0")
      end
    end
    user_types = user_classes.map(&:user_type)
    if !user_types.include?("UC2")
      user_class = UserClass.new
      user_class.user_type = "UC2"
      user_class.user_type_name="Plus"
      user_class.save
    end
  end

  def self.down
  end
end
