class CreateProperties < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.string      :title
      t.text        :description
      t.string      :country
      t.string      :city
      t.string      :street_name
      t.integer     :postal_code
      t.integer     :rental_period,      :null => false
      t.boolean     :landlord_address,    :default => false
      t.string      :category,          :null => false
      t.string      :facilities_nearby
      t.string      :transport_nearby
      t.string      :status
      t.references  :user

      t.timestamps
    end
  end

  def self.down
    drop_table :properties
  end
end
