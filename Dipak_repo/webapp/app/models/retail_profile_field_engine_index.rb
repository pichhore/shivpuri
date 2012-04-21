class RetailProfileFieldEngineIndex < ActiveRecord::Base
  uses_guid
  belongs_to :retail_buyer_profile
end
