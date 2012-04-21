class SpamClaim < ActiveRecord::Base
  belongs_to :user, :foreign_key=>"created_by_user_id"
end
