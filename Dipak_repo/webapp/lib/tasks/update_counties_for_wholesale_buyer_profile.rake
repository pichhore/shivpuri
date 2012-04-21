namespace :db do
task :update_counties_for_wholesale_buyer_profile => :environment do
  wholesale_buyer_profiles = Profile.find_all_active_wholesale_type_buyers
  wholesale_logger=Logger.new("#{RAILS_ROOT}/log/update_counties_for_whlolesale_buyer_profile.log")

  wholesale_buyer_profiles.each do |profile|
    unless profile.county.blank?
      wholesale_logger.info "already updated profile id #{profile.id}"
      puts "already updated profile id #{profile.id}"
      next
    end
    zips_string = profile.zip_code
    county_array = Array.new
    unless zips_string.blank?
      zips_string.split(",").each do |zip|
        next if zip.blank?
        zip_obj = Zip.find(:first, :conditions => ["zip = ?", zip])
        next if zip_obj.blank? or zip_obj.county_id.blank?
        county_obj = County.find(:first, :conditions => ["id = ?", zip_obj.county_id])
        next if county_obj.blank?
        county_array << county_obj.name
      end
      unless county_array.blank?
        arr = county_array
        freq = arr.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
        top_county = arr.sort_by { |v| freq[v] }.last
        county_obj = County.find(:first, :conditions => ["name = ?", top_county])
        zip_obj = Zip.find(:first, :conditions => ["county_id = ?", county_obj.id])
        profile.state = zip_obj.state
        profile.save
      end

      county_string = String.new
      unless county_array.blank?
        county_array.uniq.each do |coun|
          county_string = coun.to_s and next if county_string.blank?
          county_string = county_string+"," +coun.to_s   
        end
      end

      profile.profile_fields.each do |pf|
        if( pf.key.eql? 'county' ) then
          county_string = nil if county_string.blank?
          pf.value_text = county_string
          pf.value = county_string
          pf.save!
          break
        end
      end
    end
    pfeis = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    pfeis.each do |pfei|
      zip_obj = Zip.find(:first, :conditions => ["zip = ?", pfei.zip_code])
      next if zip_obj.blank? or zip_obj.county_id.blank?
      county_obj = County.find(:first, :conditions => ["id = ?", zip_obj.county_id])
      next if county_obj.blank?
      pfei.update_attributes(:county => county_obj.name)
    end
    puts "updated profile id #{profile.id}, state #{profile.state}, zips #{profile.zip_code}, counties #{profile.county}"
    wholesale_logger.info "updated profile id #{profile.id}, state #{profile.state}, zips #{profile.zip_code}, counties #{profile.county}"

  end
end
end