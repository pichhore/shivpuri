class Feedback < ActiveRecord::Base
  uses_guid

  validates_presence_of     :email
  validates_presence_of     :first_name
  validates_presence_of     :last_name
  validates_presence_of     :comments

end
