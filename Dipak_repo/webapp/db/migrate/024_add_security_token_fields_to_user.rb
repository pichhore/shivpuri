class AddSecurityTokenFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :security_token, :string, :limit=>40
    add_column :users, :security_token_expiry, :datetime
  end

  def self.down
    remove_column :users, :security_token
    remove_column :users, :security_token_expiry
  end
end
