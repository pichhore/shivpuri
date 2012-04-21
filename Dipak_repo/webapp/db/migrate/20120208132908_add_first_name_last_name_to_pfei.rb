class AddFirstNameLastNameToPfei < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :first_name, :string
    add_column :profile_field_engine_indices, :last_name, :string
  end

  def self.down
    remove_column :profile_field_engine_indices, :first_name
    remove_column :profile_field_engine_indices, :last_name
  end

end
