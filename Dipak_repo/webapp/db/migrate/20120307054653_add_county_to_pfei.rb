class AddCountyToPfei < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :county, :string
  end

  def self.down
    remove_column :profile_field_engine_indices, :county
  end
end
