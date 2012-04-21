class CreateLikeProperties < ActiveRecord::Migration
  def self.up
    create_table :like_properties do |t|
      t.integer     :count
      t.references  :property
      t.references  :user

      t.timestamps
    end
  end

  def self.down
    drop_table :like_properties
  end
end
