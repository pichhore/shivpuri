class CreateMyWebsites < ActiveRecord::Migration
  def self.up
    create_table :my_websites do |t|
      t.string :domain_name
      t.string :site
      t.string  :site_type
      t.timestamps
    end
  end

  def self.down
    drop_table :my_websites
  end
end
