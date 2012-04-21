class CreateCreditCardInformations < ActiveRecord::Migration
  def self.up
    create_table :credit_card_informations do |t|
      t.string :firstname
      t.string :lastname
      t.string :streetaddress
      t.string :block
      t.string :city
      t.string :state
      t.string :country
      t.string :postalcode
      t.string :expiration_month
      t.string :expiration_year
      t.string :phoneno
      t.string :aboutus
      t.references :property
      t.references :application

      t.timestamps
    end
  end

  def self.down
    drop_table :credit_card_informations
  end
end
