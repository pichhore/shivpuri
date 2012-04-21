class AddMoveinFieldsToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :client_move, :boolean, :default => false
    add_column :properties, :lord_move, :boolean, :default => false
  end

  def self.down
    remove_column :properties, :client_move
    remove_column :properties, :lord_move
  end
end
