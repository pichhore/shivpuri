class LahProductPurchasedByUser < ActiveRecord::Base

  uses_guid
  belongs_to :user
end
