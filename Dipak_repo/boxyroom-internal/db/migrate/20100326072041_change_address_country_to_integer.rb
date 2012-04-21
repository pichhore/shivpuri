class ChangeAddressCountryToInteger < ActiveRecord::Migration
  def self.up
    add_column :addresses, :country_id, :integer
    remove_column :addresses, :country
  end

  def self.down
    add_column :addresses, :country, :string
    remove_column :addresses, :country_id
  end
end
