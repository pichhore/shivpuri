class AddreceivedAmountToCreditCardInformation < ActiveRecord::Migration
  def self.up
    add_column :credit_card_informations, :received_amount, :string
  end

  def self.down
    remove_column :credit_card_informations, :received_amount
  end
end
