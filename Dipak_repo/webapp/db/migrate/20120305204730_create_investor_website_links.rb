class CreateInvestorWebsiteLinks < ActiveRecord::Migration
  def self.up
    create_table :investor_website_links, :options => 'ENGINE=MyISAM' do |t|
      t.column :investor_website_id, :string, :limit => 36, :null => false
      t.column :link_name_1, :string
      t.column :link_url_1, :string
      t.column :link_name_2, :string
      t.column :link_url_2, :string
      t.column :link_name_3, :string
      t.column :link_url_3, :string
      t.column :link_name_4, :string
      t.column :link_url_4, :string
      t.column :link_name_5, :string
      t.column :link_url_5, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :investor_website_links
  end
end
