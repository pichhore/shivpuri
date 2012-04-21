class AddCountryAndStateToProfile < ActiveRecord::Migration
  def self.up
    add_column "syndicate_properties", "country", :string , :default => "US"
    add_column "syndicate_properties", "state", :string 
  end

  def self.down
    remove_column "syndicate_properties", "country"
    remove_column "syndicate_properties", "state"
  end
end
