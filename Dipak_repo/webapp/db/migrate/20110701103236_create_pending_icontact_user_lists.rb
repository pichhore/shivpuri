class CreatePendingIcontactUserLists < ActiveRecord::Migration
  def self.up
    create_table :pending_icontact_user_lists do |t|
      t.string :user_id, :limit => 36, :references => :users
      t.string :list_name
      t.string :list_id_detail

      t.timestamps
    end
  end

  def self.down
    drop_table :pending_icontact_user_lists
  end
end
