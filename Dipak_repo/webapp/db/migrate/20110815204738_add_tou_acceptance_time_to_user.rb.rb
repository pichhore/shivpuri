class AddTouAcceptanceTimeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :tou_accepted_at, :datetime, :default => nil
  end

  def self.down
    remove_column :users, :tou_accepted_at
  end
end
