class SqueezePageOptIn < ActiveRecord::Base
  uses_guid
  belongs_to :user_territory

  validates_presence_of     :retail_buyer_first_name
  validates_presence_of     :retail_buyer_email
  #validates_uniqueness_of   :retail_buyer_email, :case_sensitive => false
  validates_format_of       :retail_buyer_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
