class AddColumnsToSyndicateProperties < ActiveRecord::Migration
  def self.up
    add_column :syndicate_properties, :published_date, :date
    add_column :syndicate_properties, :latitude, :float
    add_column :syndicate_properties, :longitude, :float
  end

  def self.down
    remove_column :syndicate_properties, :longitude
    remove_column :syndicate_properties, :latitude
    remove_column :syndicate_properties, :published_date
  end
end
