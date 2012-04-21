class AddRowToActivityCategory < ActiveRecord::Migration
  def self.up
    execute "INSERT into activity_categories (id, name) VALUES ('cat_buyer_prof_deleted', 'Retail Buyer Profile Deleted')"

  end

  def self.down
  end
end
