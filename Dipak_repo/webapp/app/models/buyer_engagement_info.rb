class BuyerEngagementInfo < ActiveRecord::Base
  # uses_guid
  belongs_to :retail_buyer_profile
  belongs_to :profile
end
