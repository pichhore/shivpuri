class SellerLeadOptIn < ActiveRecord::Base
  uses_guid
  belongs_to :seller_website

  validates_presence_of     :seller_first_name
  validates_presence_of     :seller_email
  validates_uniqueness_of   :seller_email, :case_sensitive => false
  validates_format_of       :seller_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
end
