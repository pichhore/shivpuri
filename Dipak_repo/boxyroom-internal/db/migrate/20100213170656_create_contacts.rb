class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.references :contactable, :polymorphic => true

      t.string :relationship

      t.string :first_name
      t.string :last_name
      
      t.string :email
      t.string :phone_no
      t.string :mobile_no
      t.string :fax_no

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
