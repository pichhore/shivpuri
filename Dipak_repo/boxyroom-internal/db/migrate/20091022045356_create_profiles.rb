class CreateProfiles < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :profiles
  end
end
