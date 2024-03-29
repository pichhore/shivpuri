class CreateLatlongs < ActiveRecord::Migration
  def self.up
    unless Latlong.table_exists?    
      create_table :latlongs, :options => 'ENGINE=MyISAM' do |t|
        t.column :seq,   :integer, :null => false
        t.column :lat,   :float,   :null => false
        t.column :lng,   :float,   :null => false
      
        t.column :zcta_id, :integer, :null => false
      end
    
      #load the dataset
       say_with_time "loading latlong dataset" do
         fn = File.dirname(__FILE__) + "/../zcta_dat/zcta_48.dat"
           
         File.open(fn,"r").read.split("\n").each do |x|
           xx = x.split(',')        
          z = Zcta.find_by_zcta( xx[0].to_i )
         
           Latlong.create( :seq => xx[1].to_i, :lat => xx[2].to_f, :lng => xx[3].to_f, :zcta_id => z.id ) unless z == nil
         end
       end
    end
  end

  def self.down
    if Latlong.table_exists?
      drop_table :latlongs
    end
  end
end
