namespace "zcta" do

  # allow ~ 5 minutes
  task(:load_zips => :environment) do

    Zip.delete_all

    fn = RAILS_ROOT + "/db/zcta_dat/zips.txt"

    File.open(fn,"r").read.split("\n").each do |x|
      xx = x.split(',')
      
      Zip.create( :zip => xx[1].gsub!(/^"(.*?)"$/,'\1'), :state => xx[2].gsub!(/^"(.*?)"$/,'\1'), :city => xx[3].gsub!(/^"(.*?)"$/,'\1'), :lng => '-' + xx[4], :lat => xx[5] )
    end
  end

  # allow ~ 10 minutes
  task(:load_zctas => :environment) do

    Zcta.delete_all
    
    # find and import zip_XX.csv files
    Dir[ RAILS_ROOT + '/db/zcta_dat/zip_??.csv' ].each do |fn|
      
      # construct state portion of id from filename
      state_id = fn[ fn.length - 6, 2 ].to_i * 10000
      
      File.open(fn,"r").read.split("\n").each do |x|
        
        xx = x.split(',')        
        z = Zip.find_by_zip( xx[1] )
      
        if z == nil then
          if xx[1] =~ /\d{5,5}/ then
            z = Zip.create( :zip => xx[1] )
          end
        end
      
        Zcta.create( :zcta => xx[0].to_i + state_id, :zip_id => z.id ) unless z == nil
      end
    end
  end

  # allow ~ 1 hour
  task(:load_latlongs => :environment) do

    Latlong.delete_all
    Latlong.logger.level = Logger::ERROR
    
    # disable indexing during insert
    Latlong.connection.execute "ALTER TABLE latlongs DISABLE KEYS"
    
    Latlong.transaction do
      
      # find and import zip_XX.csv files
      Dir[ RAILS_ROOT + '/db/zcta_dat/zcta_??.csv' ].each do |fn|

        # give some progress indication
        puts 'processing ' + fn + ' @ ' + Time.new.to_s
    
        # construct state portion of id from filename
        state_id = fn[ fn.length - 6, 2 ].to_i * 10000

        # set up for next state
        inserts = []
        current_zcta = 0
        z = nil

        File.open(fn,"r").read.split("\n").each do |x|
          xx = x.split(',')
          
          zcta = xx[0].to_i + state_id
          
          seq = xx[1].to_i
          lat = xx[2].to_f
          lng = xx[3].to_f
          
          # skip masks
          next if seq < 0 or lat == 0
          
          # grab associated zcta
          z = Zcta.connection.select_value( "SELECT id FROM zctas WHERE zcta = #{zcta}" ) unless zcta == current_zcta

          # skip if no associated zcta
          next unless z

          # track current zcta
          current_zcta = zcta

          # write out latlong
          inserts.push "(#{seq},#{lat},#{lng},#{z.to_i})"
        end

        Latlong.connection.execute "INSERT INTO latlongs (seq,lat,lng,zcta_id) VALUES #{ inserts.join( ',' ) }"
      end
    end
    
    # now re-enable indexing
    puts 'indexing @ ' + Time.new.to_s
    
    Latlong.connection.execute "ALTER TABLE latlongs ENABLE KEYS"    
  end
    
  # allow ~ 1 minute
  task(:fixup_zips => :environment) do
    
    Zip.find( :all, :conditions => [ 'lat IS NULL' ] ).each do |zip|
      
      if( ll = zip.zctas.first.latlongs.find( :first, :conditions => [ 'seq = 0' ] ) )
      
        zip.lat = ll.lat
        zip.lng = ll.lng
        
        zip.save
      end
    end
  end
end