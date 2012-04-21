class CreateZips < ActiveRecord::Migration
  def self.up
    unless Zip.table_exists?    
      create_table :zips, :options => 'ENGINE=MyISAM' do |t|
        t.column :zip,   :string,  :limit => 5, :null => false
        t.column :state, :string
        t.column :city,  :string
        t.column :lat,   :float
        t.column :lng,   :float
      end
    
      add_index :zips, :zip
    
      #load the dataset
      say_with_time "loading zip dataset" do
        fn = File.dirname(__FILE__) + "/../zcta_dat/zip_00.dat"
    
        File.open(fn,"r").read.split("\n").each do |x|
          xx = x.split(',')
          Zip.create( :zip => xx[0], :state => xx[1], :city => xx[2], :lat => xx[3], :lng => xx[4] )
        end
      end
    end
  end

  def self.down
    if Zip.table_exists?
      remove_index :zips, :zip
      drop_table :zips
    end
  end
end
