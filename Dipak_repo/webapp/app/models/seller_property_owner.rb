class SellerPropertyOwner < ActiveRecord::Base
  uses_guid
  belongs_to :seller_property_profile
end
