class DropProfileMatchesTable < ActiveRecord::Migration
  def self.up
    drop_table :profile_matches
  end

  def self.down
  end
end
