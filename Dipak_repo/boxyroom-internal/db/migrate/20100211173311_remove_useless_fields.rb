class RemoveUselessFields < ActiveRecord::Migration
  def self.up
    # applications
    remove_column :applications, :landlord_cancel
    remove_column :applications, :tenant_cancel

    # properties
    remove_column :properties, :client_move
    remove_column :properties, :lord_move
    remove_column :properties, :facilities_nearby
    remove_column :properties, :transport_nearby
    remove_column :properties, :country_id

    # users
    remove_column :users, :level

    drop_table :countries
    drop_table :profiles
  end

  def self.down
    # applications
    add_column :applications, :landlord_cancel, :boolean
    add_column :applications, :tenant_cancel, :boolean

    # properties
    add_column :properties, :client_move, :boolean
    add_column :properties, :lord_move, :boolean
    add_column :properties, :facilities_nearby, :string
    add_column :properties, :transport_nearby, :string
    add_column :properties, :country_id, :integer

    # users
    add_column :users, :level, :integer

    create_table :countries do |t|
      t.string    :name
    end

    create_table :profiles do |t|
      t.string :name
      t.references :user
      t.string :gender
      t.string :full_name
      t.string :country
      t.text :address
      t.string :home_no
      t.string :work_no
      t.string :mobile_no
      t.date :date_of_birth
      t.date :duration_at_current_address
      t.string :current_landlord_name
      t.string :current_landlord_no
      t.text :reasons_for_leaving
      t.integer :no_of_pets
      t.string :pets_breed
      t.string :company_name
      t.date :work_start_date
      t.date :work_end_date
      t.string :work_admin_name
      t.string :work_admin_no
      t.string :work_admin_email
      t.string :reference_name
      t.string :reference_relationship
      t.string :reference_no

      t.timestamps
    end
  end
end
