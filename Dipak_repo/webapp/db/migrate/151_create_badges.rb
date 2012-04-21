class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badges do |t|
      t.string :name
      t.integer :profiles_added
      t.integer :properties_added
      t.integer :properties_sold
      t.string :certification
      t.integer :membership_time
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table :badges
  end
end

