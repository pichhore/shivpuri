class ChangeIdentificationTypeToString < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :identification_type
    add_column :profiles, :identification_type, :string
  end

  def self.down
    remove_column :profiles, :identification_type
    add_column :profiles, :identification_type, :integer
  end
end
