class AddMonthlyrentalToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :monthly_rental, :float
  end

  def self.down
    remove_column :properties, :monthly_rental
  end
end
