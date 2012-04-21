namespace :db do
  desc 'This updates the directions to the zips table.  Set RAILS_ENV to override.'
	task :add_directions_to_zips => :environment do
    begin      
      Zip.update_all("direction = 'NW'", "zip LIKE 78726")
      Zip.update_all("direction = 'NW'", "zip LIKE 78729")
      Zip.update_all("direction = 'NW'", "zip LIKE 78730")
      Zip.update_all("direction = 'NW'", "zip LIKE 78731")
      Zip.update_all("direction = 'NW'", "zip LIKE 78732")
      Zip.update_all("direction = 'NW'", "zip LIKE 78750")
      Zip.update_all("direction = 'NW'", "zip LIKE 78759")
      Zip.update_all("direction = 'NW'", "zip LIKE 78758")
      Zip.update_all("direction = 'NW'", "zip LIKE 78757")
      Zip.update_all("direction = 'NW'", "zip LIKE 78751")
      Zip.update_all("direction = 'NW'", "zip LIKE 78705")
      Zip.update_all("direction = 'NW'", "zip LIKE 78756")
      Zip.update_all("direction = 'NW'", "zip LIKE 78727")
      Zip.update_all("direction = 'NW'", "zip LIKE 78734")
      Zip.update_all("direction = 'NW'", "zip LIKE 78717")
      Zip.update_all("direction = 'NW'", "zip LIKE 78728")      
      
      
      Zip.update_all("direction = 'NE'", "zip LIKE 78753")
      Zip.update_all("direction = 'NE'", "zip LIKE 78754")
      
      
      Zip.update_all("direction = 'SW'", "zip LIKE 78704")
      Zip.update_all("direction = 'SW'", "zip LIKE 78735")
      Zip.update_all("direction = 'SW'", "zip LIKE 78736")
      Zip.update_all("direction = 'SW'", "zip LIKE 78737")
      Zip.update_all("direction = 'SW'", "zip LIKE 78739")
      Zip.update_all("direction = 'SW'", "zip LIKE 78745")
      Zip.update_all("direction = 'SW'", "zip LIKE 78748")
      Zip.update_all("direction = 'SW'", "zip LIKE 78749")
      Zip.update_all("direction = 'SW'", "zip LIKE 78746")
      Zip.update_all("direction = 'SW'", "zip LIKE 78738")
      Zip.update_all("direction = 'SW'", "zip LIKE 78733")
      
      
      Zip.update_all("direction = 'SE'", "zip LIKE 78719")
      Zip.update_all("direction = 'SE'", "zip LIKE 78725")
      Zip.update_all("direction = 'SE'", "zip LIKE 78741")
      Zip.update_all("direction = 'SE'", "zip LIKE 78742")
      Zip.update_all("direction = 'SE'", "zip LIKE 78744")
      Zip.update_all("direction = 'SE'", "zip LIKE 78747")
      Zip.update_all("direction = 'SE'", "zip LIKE 78617")
      
 	    Zip.update_all("direction = 'NW,SW'", "zip LIKE 78701")
      Zip.update_all("direction = 'NW,SW'", "zip LIKE 78703")
      Zip.update_all("direction = 'NW,SW'", "zip LIKE 78705")
      Zip.update_all("direction = 'NW,NE'", "zip LIKE 78753")
      Zip.update_all("direction = 'NW,NE'", "zip LIKE 78752")
      Zip.update_all("direction = 'SE,NE'", "zip LIKE 78721")
      Zip.update_all("direction = 'SE,NE'", "zip LIKE 78722")
      Zip.update_all("direction = 'SE,NE'", "zip LIKE 78723")
      Zip.update_all("direction = 'SE,NE'", "zip LIKE 78724")
      Zip.update_all("direction = 'SE,NE'", "zip LIKE 78702")
      
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78664")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78680")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78681")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78682")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78683")
      
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78660")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78691")
      
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78613")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78630")
      
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78641")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78645")
      Zip.update_all("direction = 'NE,NW,SE,SW'", "zip LIKE 78646")

      puts "Zip codes updated successfully."
    rescue => e
      puts "#{e.message}"
    end
	end
end
