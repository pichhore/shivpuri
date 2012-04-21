class AddProfileTypeToReview < ActiveRecord::Migration
  def self.up
    add_column :reviews, :profile_type, :string
  end

  def self.down
    remove_column :reviews, :profile_type
  end
end
