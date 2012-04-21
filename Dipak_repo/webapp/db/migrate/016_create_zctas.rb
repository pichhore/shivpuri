class CreateZctas < ActiveRecord::Migration
  def self.up
    unless Zcta.table_exists?    
      create_table :zctas, :options => 'ENGINE=MyISAM' do |t|
        t.column :zcta,  :integer, :null => false
        t.column :zip_id, :integer, :null => false
      end

      #load the dataset
      say_with_time "loading zcta dataset" do
        fn = File.dirname(__FILE__) + "/../zcta_dat/zip_48.dat"
    
       File.open(fn,"r").read.split("\n").each do |x|
          xx = x.split(',')        
          z = Zip.find_by_zip( xx[1] )
        
          if z == nil then
            if xx[1] =~ /\d{5,5}/ then
              z = Zip.create( :zip => xx[1] )
            end
          end
        
          Zcta.create( :zcta => xx[0].to_i, :zip_id => z.id ) unless z == nil
        end
      end
    end
  end

  def self.down
    if Zcta.table_exists?
      drop_table :zctas
    end
  end
end