# run this from script/console:  >> require 'db/load_latlongs'
#   allow 20 mins or more to complete

# load the texas latlong dataset
fn = File.dirname(__FILE__) + "/zcta_dat/zcta_48.dat"
  
File.open(fn,"r").read.split("\n").each do |x|
  xx = x.split(',')        
  z = Zcta.find_by_zcta( xx[0].to_i )

  Latlong.create( :seq => xx[1].to_i, :lat => xx[2].to_f, :lng => xx[3].to_f, :zcta_id => z.id ) unless z == nil
end
