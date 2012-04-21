class AddVerifiedToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :verified, :string
  end

  def self.down
     remove_column :properties, :verified
  end
end
