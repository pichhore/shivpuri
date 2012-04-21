class AddThreeFieldsToBadges < ActiveRecord::Migration
  def self.up
    add_column :badges, :sellers_added, :integer
    add_column :badges, :deals_completed, :integer
    add_column :badges, :investor_messages_sent, :integer
  end

  def self.down
    remove_column :badges, :sellers_added
    remove_column :badges, :deals_completed
    remove_column :badges, :investor_messages_sent
  end
end
