class ProfileFieldEngineIndex < ActiveRecord::Base
  uses_guid
  belongs_to :profile, :include => :profile_fields
  acts_as_paranoid

  acts_as_xapian :texts => [ :zip_code, :beds, :baths, :profile_type_id, :first_name, :last_name, :notification_phone, :notification_email],
    :terms => [ [ :zip_code, 'R', "zip" ], [:beds, 'B', "beds"], [:baths, 'C', "baths"], [:profile_type_id, 'Q', "profile_type"], [:first_name, 'F', "first_name"], [:last_name, 'L', "last_name"], [:notification_phone, 'H', "notification_phone"], [:notification_email, 'N', "notification_email"]]

  def self.refresh_indices_old(profiles=Profile.find(:all))
    # NOTE: required for an older migration
    profiles.each { |profile| profile.save! }
  end

  def self.refresh_indices
    # paginate 10 at a time, ask the observer to update the indices
    offset = 0
    per_page = 10
    total = Profile.count("id", :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
    begin
      puts "Processing #{offset+1} - #{(offset+per_page)} of approx #{total}"
      profiles = Profile.find(:all, :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
      profiles.each do |profile|
        # update the profile's index
        refresh_index_for(profile)
      end
      offset += per_page
    end while profiles.length > 0
  end

  def self.refresh_index_for(profile)
    # puts "1 after save"
    pfeis = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    pfeis.each do |pfei|
      ProfileFieldEngineIndex.delete( pfei.id )
    end unless pfeis == nil

    # puts "2 after save"

    # grab associated key-value pairs
    dict = Hash.new
    profile.profile_fields.each do |pf|
      if( [ 'property_type', 'beds', 'baths', 'square_feet', 'square_feet_min', 'square_feet_max',
            'price', 'price_min', 'price_max','max_mon_pay','max_dow_pay','min_mon_pay','min_dow_pay', 'units', 'units_min', 'units_max',
            'acres', 'acres_min', 'acres_max', 'privacy','contract_end_date','notification_active','notification_email', 'notification_phone', 'after_repair_value', 'value_determined_by', 'total_repair_needed', 'repair_calculated_by', 'max_purchase_value', 'arv_repairs_value', 'first_name', 'last_name' ].include?( pf.key ) ) then
        dict[ pf.key ] = pf.value_text || pf.value
      # else
          @flag_fn = true if pf.key == "first_name"
          @flag_ln = true if pf.key == "last_name"
      end
    end

    if !@flag_fn && profile.retail_buyer_profile
      ProfileField.create(:profile_id => profile.id, :key => "first_name", :value => profile.retail_buyer_profile.first_name, :value_text => profile.retail_buyer_profile.first_name)
    end
    if !@flag_ln && profile.retail_buyer_profile
      ProfileField.create(:profile_id => profile.id, :key => "last_name", :value => profile.retail_buyer_profile.last_name, :value_text => profile.retail_buyer_profile.last_name)
    end

    # puts "3 after save"
    # create a separate row for each zip code
    zip_codes = profile.profile_fields.find_by_key( 'zip_code' )
    counties = profile.profile_fields.find_by_key( 'county' )
    zip_codes_text = zip_codes.value_text || zip_codes.value if zip_codes
        if profile.buyer? and profile.country ==  "CA"
          zips = Zip.find(:all, :conditions => ["city =? && state=? && country=?",profile.city, profile.state,profile.country])
          a = String.new
          zips.each do |i|
            a << i.zip.to_s+','
            end
          zip_codes_text = a.to_s.chop
        end
    # puts "4 after save: #{zip_codes_text}"
    counties = counties.value_text || counties.value
    unless counties.blank?
      first_zip = zip_codes_text
      zip_codes_text = counties
    end 
    if(zip_codes_text)
      # puts "5 after save"
#       zip_codes_text.split(/[^0-9]+/).each do |z|
        zip_codes_text.split(",").each do |z|
        # ticket #682, duplicate records created for extended zip code for properties
        if !z.nil?
          # puts "6 after save"
          pfei = ProfileFieldEngineIndex.new do |p|
            # puts "7 after save"
            p.profile_id = profile.id
            if !@flag_fn && profile.retail_buyer_profile
              p.first_name = profile.retail_buyer_profile.first_name
            else
              p.first_name = dict['first_name']
            end
            if !@flag_ln && profile.retail_buyer_profile
              p.last_name = profile.retail_buyer_profile.last_name
            else
              p.last_name = dict['last_name']
            end
            unless counties.blank?
              p.county = z
              p.zip_code = first_zip
            else
              p.zip_code = z
            end 
            p.property_type = dict[ 'property_type' ]
            p.property_type_sort_order = calc_property_type_sort_order(dict[ 'property_type' ])
            p.beds = formatted_string_to_i(dict[ 'beds' ])
            p.baths = formatted_string_to_i(dict[ 'baths' ])
            p.square_feet = formatted_string_to_i(dict[ 'square_feet' ])
            p.square_feet_min = formatted_string_to_i(dict['square_feet_min'])
            p.square_feet_max = formatted_string_to_i(dict[ 'square_feet_max' ])
            p.price = formatted_string_to_i(dict[ 'price' ])
            p.price_min = formatted_string_to_i(dict[ 'price_min' ])
            p.price_max = formatted_string_to_i(dict[ 'price_max' ])
            p.units = formatted_string_to_i(dict[ 'units' ])
            p.units_min = formatted_string_to_i(dict[ 'units_min' ])
            p.units_max = formatted_string_to_i(dict[ 'units_max' ])
            p.acres = formatted_string_to_i(dict[ 'acres' ])
            p.acres_min = formatted_string_to_i(dict[ 'acres_min' ])
            p.acres_max = formatted_string_to_i(dict[ 'acres_max' ])
            p.max_mon_pay = formatted_string_to_i(dict[ 'max_mon_pay' ])
            p.max_dow_pay = formatted_string_to_i(dict[ 'max_dow_pay' ])
            p.min_mon_pay = formatted_string_to_i(dict[ 'min_mon_pay' ])
            p.min_dow_pay = formatted_string_to_i(dict[ 'min_dow_pay' ])
            p.privacy = dict[ 'privacy' ] || "private"
            p.contract_end_date = dict[ 'contract_end_date' ]
            p.notification_active = dict[ 'notification_active' ]
            p.notification_email = dict[ 'notification_email' ]
            p.notification_phone = dict[ 'notification_phone' ]
            p.deal_terms = dict[ 'deal_terms' ]
            p.video_tour = dict[ 'video_tour' ]
            p.embed_video = dict[ 'embed_video' ]
#   Wholesale 
            p.after_repair_value = formatted_string_to_i(dict['after_repair_value'])
            p.value_determined_by = (dict['value_determined_by']).to_s
            p.total_repair_needed = formatted_string_to_i(dict['total_repair_needed'])
            p.repair_calculated_by = (dict['repair_calculated_by']).to_s
# ..........
# Owner finance
            p.max_purchase_value = formatted_string_to_i(dict['max_purchase_value'])
            p.arv_repairs_value = formatted_string_to_i(dict['arv_repairs_value'])
            
# ..........
            p.is_owner = ( profile.profile_type == ProfileType.OWNER ) || ( profile.profile_type == ProfileType.SELLER_AGENT )
            p.has_profile_image = ( profile.profile_images.count("id", { }) > 0 )
            
            # Ticket #544 - new index values
            p.profile_created_at = profile.created_at
            p.has_features = (!profile.field_value(:feature_tags).nil? and !profile.field_value(:feature_tags).empty?)
            p.has_description = (!profile.field_value(:description).nil? and !profile.field_value(:description).empty?)
            p.profile_type_id = profile.profile_type_id
            p.user_id = profile.user_id
            
            # Ticket #544 - is it the first in the list of buyer profiles for the user and mark it as is_primary_profile
            profile_results = ProfileField.connection.select_all("SELECT id from profiles where user_id = '#{profile.user_id}' AND profile_type_id = 'ce5c2320-4131-11dc-b431-009096fa4c28' and deleted_at is NULL ORDER BY created_at ASC LIMIT 1")
            # default value
            p.is_primary_profile = false
            # if the results is 0, this is the first profile and should be set to true
            p.is_primary_profile = true if (profile_results.length == 0)
            # otherwise, set it to true if the first id from the query above matches the profile we are indexing
            p.is_primary_profile = true if (profile_results.length > 0 and profile_results[0]["id"] == profile.id)
          end
          
          # puts "8 after save"
          pfei.save
          # puts "9 after save"
        end
      end
    end
  end

  def active?
    status == "active" 
  end

  def is_owner?
    is_owner
  end

  protected

  # Handle numbers with commas
  def self.formatted_string_to_i(num)
    return 0 if num.nil?
    raw_value = num.to_s.delete(",")
    int_value = raw_value.to_i
    max = 2**31-1
    return int_value > max ? max : int_value # columns are defined as int(11) so avoid overflow
  end
  
  def self.calc_property_type_sort_order(property_type)
    return 1 if property_type == "single_family"
    return 2 if property_type == "multi_family"
    return 3 if property_type == "condo_townhome"
    return 4 if property_type == "vacant_lot"
    return 5 if property_type == "acreage"
    return 99
  end
  
  def self.max_mon_payment(profile_id)
    self.find_by_profile_id(profile_id).max_mon_pay
  end
  
  def self.max_down_payment(profile_id)
    self.find_by_profile_id(profile_id).max_dow_pay
  end
  
  def self.contract_end_date(profile_id)
     self.find_by_profile_id(profile_id).contract_end_date unless self.find_by_profile_id(profile_id).nil?
  end
  
  def self.profile_id(profile_id)
    self.find_by_profile_id(profile_id)
  end
  
  def self.beds(profile_id)
    self.find_by_profile_id(profile_id).beds
  end
  
  def self.baths(profile_id)
    self.find_by_profile_id(profile_id).baths
  end
  
  def self.square_feet(profile_id)
    self.find_by_profile_id(profile_id).square_feet
  end 
  
  def self.price(profile_id)
    self.find_by_profile_id(profile_id).price
  end   
  
  def self.features(profile_id)
    if self.find_by_profile_id(profile_id).has_features
      profile = ProfileField.find(:first,:conditions => ["profile_id LIKE  '#{profile_id.id}' and `key` LIKE 'feature_tags'"])
      profile.value_text if !profile.nil?        
    else
      return '(not provided)'
    end
  end 
  
end