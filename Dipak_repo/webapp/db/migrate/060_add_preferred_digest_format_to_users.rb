class AddPreferredDigestFormatToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :preferred_digest_format, :string, :limit=>10, :default=>'html'
  end

  def self.down
    remove_column :users, :preferred_digest_format
  end
end
