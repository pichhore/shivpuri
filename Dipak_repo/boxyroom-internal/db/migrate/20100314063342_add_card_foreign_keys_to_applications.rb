class AddCardForeignKeysToApplications < ActiveRecord::Migration
  def self.up
    add_column :applications, :card_id, :integer
    add_column :applications, :landlord_id, :integer

    add_column :profiles, :guardian_id, :integer
    add_column :profiles, :superior_id, :integer
  end

  def self.down
    remove_column :applications, :card_id
    remove_column :applications, :landlord_id

    remove_column :profiles, :guardian_id
    remove_column :profiles, :superior_id
  end
end
