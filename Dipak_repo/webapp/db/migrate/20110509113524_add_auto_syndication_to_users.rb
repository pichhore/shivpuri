class AddAutoSyndicationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :auto_syndication, :boolean, :default => true
  end

  def self.down
    remove_column :users, :auto_syndication
  end
end
