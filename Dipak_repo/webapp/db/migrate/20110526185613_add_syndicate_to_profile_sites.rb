class AddSyndicateToProfileSites < ActiveRecord::Migration
  def self.up
    add_column :profile_sites, :syndicated, :boolean, :default => 0
  end

  def self.down
    remove_column :profile_sites, :syndicated
  end
end
