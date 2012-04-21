class CreateAds < ActiveRecord::Migration
  def self.up
    exists = Ad.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table ads..."
        create_table :ads, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :name, :string, :null => false
          t.column :height, :integer, :null => false
          t.column :width, :integer, :null => false
          t.column :image_path, :string, :null => false
          t.column :link, :string, :null => false
          t.column :target_page, :string
          t.column :created_at, :datetime, :null => false
          t.column :deleted_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE ads ADD PRIMARY KEY (id)"

        puts "Adding index on name"
        add_index :ads, :name
        puts "Adding index on target_page"
        add_index :ads, :target_page

        puts "Installing the soft launch ads"
        Ad.create!({ :name=>"manana", :width=>240, :height=>150, :image_path=>"/images/ads/manana-bannerad.jpg", :link=>"http://www.mananafunding.com" })
        Ad.create!({ :name=>"homefixers", :width=>240, :height=>150, :image_path=>"/images/ads/homefixers-bannerad.jpg", :link=>"http://www.homefixers.com" })
        Ad.create!({ :name=>"arredondo", :width=>240, :height=>150, :image_path=>"/images/ads/arredondo-bannerad.jpg", :link=>"http://www.arredondogroup.com" })
        Ad.create!({ :name=>"gambrell", :width=>240, :height=>150, :image_path=>"/images/ads/gambrell.jpg", :link=>"mailto:leighgambrell@sbcglobal.net" })
      end
    end
  end

  def self.down
    exists = Ad.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table ads..."
        drop_table :ads
      end
    end
  end
end
