class InsertBasicUserClass < ActiveRecord::Migration
  def self.up
    user_classes = UserClass.find(:all)
    user_types = user_classes.map(&:user_type)
    unless user_types.include?("BASIC")
      user_class = UserClass.new
      user_class.user_type = "BASIC"
      user_class.save
    end
  end

  def self.down
  end
end
