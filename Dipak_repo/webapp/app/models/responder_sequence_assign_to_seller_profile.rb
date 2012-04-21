class ResponderSequenceAssignToSellerProfile < ActiveRecord::Base

  belongs_to :seller_property_profile
  belongs_to :seller_responder_sequence
end
