class AddcardnoToCreditCardInformation < ActiveRecord::Migration
  def self.up
       add_column :credit_card_informations, :cardno ,:string
  end

  def self.down
       remove_column :credit_card_informations, :cardno
  end
end
