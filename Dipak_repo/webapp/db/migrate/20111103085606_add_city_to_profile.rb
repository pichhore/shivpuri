class AddCityToProfile < ActiveRecord::Migration
 def self.up
    add_column "profiles", "state", :string
    add_column "profiles", "city", :string
  end

  def self.down
    remove_column "profiles", "state"
    remove_column "profiles", "city"
  end
end
