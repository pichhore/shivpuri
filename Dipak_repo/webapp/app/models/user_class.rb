class UserClass < ActiveRecord::Base
  has_many :users, :dependent => :nullify
  has_many :alert_definitions, :dependent=>:destroy

  def self.free_user
     self.find_by_user_type(BASIC_USER_CLASS[:basic_type]).id
  end
end
