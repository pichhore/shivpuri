class AddccvToCreditCardInformation < ActiveRecord::Migration
  def self.up
      add_column :credit_card_informations, :ccv, :string
  end

  def self.down
     remove_column :credit_card_informations, :ccv
  end
end
