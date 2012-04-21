class AddProfileOnRetailBuyer < ActiveRecord::Migration
  def self.up
    add_column :retail_buyer_profiles, :profile_id, :string, :limit => 36
  end

  def self.down
    remove_column :retail_buyer_profiles, :profile_id
  end
end
