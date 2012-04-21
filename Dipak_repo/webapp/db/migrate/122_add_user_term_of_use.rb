class AddUserTermOfUse < ActiveRecord::Migration
  def self.up
    add_column :retail_buyer_profiles, :terms_of_use, :string, :null => false
  end

  def self.down
    remove_column :retail_buyer_profiles, :terms_of_use
  end
end
