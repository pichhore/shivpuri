class AddLocalPhoneColumnToBuyerWebPage < ActiveRecord::Migration
  def self.up
    add_column :buyer_web_pages, :local_phone, :string
  end

  def self.down
    remove_column :buyer_web_pages, :local_phone
  end
end
