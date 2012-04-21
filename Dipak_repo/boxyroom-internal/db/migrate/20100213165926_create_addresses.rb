class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.references :addressable, :polymorphic => true

      t.string :unit_no
      t.string :street_name
      t.string :postal_code
      
      t.string :city
      t.string :state
      t.string :country

      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
