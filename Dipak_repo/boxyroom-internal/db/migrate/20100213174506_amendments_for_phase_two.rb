class AmendmentsForPhaseTwo < ActiveRecord::Migration
  def self.up
    add_column :users, :gender, :string
    remove_column :users, :occupation

    add_column :applications, :expected_arrival, :date
    add_column :applications, :start_of_stay, :date
    add_column :applications, :duration_of_stay, :integer
    add_column :applications, :reason_for_leaving, :string

    add_column :properties, :floor_area, :integer
    add_column :properties, :rooms, :integer
    add_column :properties, :bathrooms, :integer

    remove_column :properties, :country
    remove_column :properties, :city
    remove_column :properties, :street_name
  end

  def self.down
    remove_column :users, :gender
    add_column :users, :occupation, :string

    remove_column :applications, :expected_arrival
    remove_column :applications, :start_of_stay
    remove_column :applications, :duration_of_stay
    remove_column :applications, :reason_for_leaving

    remove_column :properties, :floor_area
    remove_column :properties, :rooms
    remove_column :properties, :bathrooms

    add_column :properties, :country, :string
    add_column :properties, :city, :string
    add_column :properties, :street_name, :string
  end
end
