class Feed < ActiveRecord::Base

BUYER_ADDED = 1
PROPERTY_ADDED = 2
PROPERTY_SOLD = 3
PROPERTY_BOUGHT = 4
SELLER_LEAD_ADDED = 5

  belongs_to :user
  belongs_to :territory
  class << self
    def add(user_id, territory_id, activity_id)
      return false if user_id.blank? || territory_id.blank? || activity_id.blank?
      feed = Feed.new(:user_id => user_id, :territory_id => territory_id, :activity_id => activity_id)
      feed.save!
    end
  end
  
end
