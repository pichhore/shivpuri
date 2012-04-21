class AddcardtypeToCreditCardInformation < ActiveRecord::Migration
  def self.up
       add_column :credit_card_informations, :cardtype, :string
  end

  def self.down
        remove_column :credit_card_informations, :cardtype
  end
end
