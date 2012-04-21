class AddCityToProfileFieldEngineIndice < ActiveRecord::Migration
  def self.up
    add_column "syndicate_properties", "city", :string
  end

  def self.down
    remove_column "syndicate_properties", "city"
  end
end
