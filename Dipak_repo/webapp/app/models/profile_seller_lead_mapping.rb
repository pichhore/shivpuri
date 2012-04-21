class ProfileSellerLeadMapping < ActiveRecord::Base
  belongs_to :profile
  belongs_to :seller_profile
  belongs_to :seller_property_profile, :dependent => :destroy
  validates_presence_of     :profile_id
  validates_presence_of     :seller_profile_id
  validates_presence_of     :seller_property_profile_id
end
