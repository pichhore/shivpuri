class ModifyLatlng
  def self.find_null_latlng
    geo_ll_array = ProfileField.find_by_sql("select * from profile_fields where profile_fields.key = 'geo_ll' and profile_id in (select profile_id from profile_fields where profile_fields.key='latlng' && profile_fields.value is null)");
    puts geo_ll_array.inspect
    geo_ll_array.each do |gll |
      profile = Profile.find_with_deleted(:first, :conditions => {:id => gll.profile_id.to_s})
      geocoder_address =  ProfileField.find_with_deleted(:first, :conditions => {:key =>  "property_address", :profile_id => profile.id} ).value.to_s + ', ' + ProfileField.find_with_deleted(:first, :conditions => {:key =>  "zip_code", :profile_id => profile.id} ).value.to_s
      path  = '/maps/geo'
      path += '?q=' + geocoder_address.gsub(' ','+')
      path += '&key=' + ApiKey.get

      response = Net::HTTP.get_response('maps.google.com', path)
      lnglat = response.body.slice(/-*\d+\.\d+,\s*\d+\.\d+/i) # google snuck in some whitespace
      puts "=================="
      puts response.body
      puts "=================="
    # swap lnglat order (need latlng)
      latlng = nil
      latlng =  lnglat.split(',').last.strip + ',' + lnglat.split(',').first unless lnglat == nil
      temp_id = ProfileField.find_by_sql("select id from profile_fields where profile_fields.key='latlng' && profile_fields.profile_id = '#{gll.profile_id}'")
      puts temp_id.inspect
      ProfileField.connection.execute("update `profile_fields` set `created_at`='#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}', `deleted_at` = NULL, `updated_at`='#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}', `value` = '#{latlng}', `value_text` = null, `key`= 'latlng', `profile_id` = '#{gll.profile_id}' where profile_fields.id in('#{temp_id.first.id}' )") unless lnglat.nil?
    end
    
  end
end
ModifyLatlng.find_null_latlng
