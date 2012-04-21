class AddProfileDeleteDateFieldInProfile < ActiveRecord::Migration
  def self.up
     add_column :profiles, :profile_delete_date, :datetime
  end

  def self.down
     remove_column :profiles, :profile_delete_date
  end
end
