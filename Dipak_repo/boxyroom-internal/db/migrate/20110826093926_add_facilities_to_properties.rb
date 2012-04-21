class AddFacilitiesToProperties < ActiveRecord::Migration
  def self.up
  #Facilities
    add_column :properties, :parking, :boolean
    add_column :properties, :wheelchair_accessible, :boolean
    add_column :properties, :elevator_in_building, :boolean
    add_column :properties, :garden, :boolean
    add_column :properties, :balcony, :boolean

    #Amenities
    add_column :properties, :kitchen, :boolean
    add_column :properties, :freezer, :boolean
    add_column :properties, :dishwasher, :boolean
    add_column :properties, :washer, :boolean
    add_column :properties, :heating, :boolean
    add_column :properties, :shower, :boolean
    add_column :properties, :Internet, :boolean
    add_column :properties, :wifi, :boolean
    add_column :properties, :phone, :boolean
    add_column :properties, :tv, :boolean
    add_column :properties, :air_conditioning, :boolean

    #Nearby
    add_column :properties, :schools, :boolean
    add_column :properties, :bus_stops, :boolean
    add_column :properties, :railway_stations, :boolean
    add_column :properties, :shopping_centres, :boolean
    add_column :properties, :parks, :boolean
    add_column :properties, :community_facilities, :boolean
    add_column :properties, :entertainment, :boolean
    add_column :properties, :restaurants, :boolean
    add_column :properties, :recreation_centres, :boolean
    add_column :properties, :health_care, :boolean
    add_column :properties, :emergency_services, :boolean

  #Max Rental Period
  add_column :properties, :max_rental_period, :integer

  end

  def self.down
  #Remove facilities
    remove_column :properties, :parking
    remove_column :properties, :wheelchair_accessible
    remove_column :properties, :elevator_in_building
    remove_column :properties, :garden
    remove_column :properties, :balcony

    #Remove Amenities
    remove_column :properties, :kitchen
    remove_column :properties, :freezer
    remove_column :properties, :dishwasher
    remove_column :properties, :washer
    remove_column :properties, :heating
    remove_column :properties, :shower
    remove_column :properties, :Internet
    remove_column :properties, :wifi
    remove_column :properties, :phone
    remove_column :properties, :tv
    remove_column :properties, :air_conditioning

    #Remove Nearby
    remove_column :properties, :schools
    remove_column :properties, :bus_stops
    remove_column :properties, :railway_stations
    remove_column :properties, :shopping_centres
    remove_column :properties, :parks
    remove_column :properties, :community_facilities
    remove_column :properties, :entertainment
    remove_column :properties, :restaurants
    remove_column :properties, :recreation_centres
    remove_column :properties, :health_care
    remove_column :properties, :emergency_services

    #Remove Rental Period
    remove_column :properties, :max_rental_period
  end
end

