class AddHoldOfferColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :hold_offer, :boolean, :default => false
  end

  def self.down
    remove_column :users, :hold_offer
  end
end
