class ShoppingCartOrderTransactionFailure < ActiveRecord::Base
  uses_guid
  belongs_to :user
end
