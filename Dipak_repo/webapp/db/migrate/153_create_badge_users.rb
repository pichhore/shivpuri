class CreateBadgeUsers < ActiveRecord::Migration
  def self.up
    create_table :badge_users do |t|
      t.column :user_id, :string, :limit => 36, :null => false
      t.column :badge_id, :integer, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :badge_users
  end
end
