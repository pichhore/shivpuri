class AddDirectionToZips < ActiveRecord::Migration
  def self.up
    add_column :zips, :direction, :string
  end

  def self.down
    remove_column :zips, :direction
  end
end
