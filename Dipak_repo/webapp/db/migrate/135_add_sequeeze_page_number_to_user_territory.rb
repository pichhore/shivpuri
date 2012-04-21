class AddSequeezePageNumberToUserTerritory < ActiveRecord::Migration
  def self.up
    add_column :user_territories,:sequeeze_page_number,:integer,:default=>0
  end

  def self.down
    remove_column :user_territories,:sequeeze_page_number
  end
end
