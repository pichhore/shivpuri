class AddIsActiveToSyndicateProperties < ActiveRecord::Migration
  def self.up
    add_column :syndicate_properties, :is_active, :boolean, :default=>true
  end

  def self.down
    remove_column :syndicate_properties, :default
  end
end
