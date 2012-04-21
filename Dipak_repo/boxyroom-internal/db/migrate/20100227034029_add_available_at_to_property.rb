class AddAvailableAtToProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :available_at, :date
  end

  def self.down
    remove_column :properties, :available_at
  end
end
