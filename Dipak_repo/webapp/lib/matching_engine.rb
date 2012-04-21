class MatchingEngine

  #
  # Returns an array of Profiles that match given a short list of matching criteria
  # (often, this is the method used by the UI as a teaser before a user signs up)
  #
  # Arguments:
  #
  #  :profile_type     required    ProfileType to match
  #  :zip_code         required    the zipcode to match
  #  :property_type    optional    the property type (defaults to "single_family")
  #  :offset           optional    the starting index of the results to return (default start with the first)
  #  :sort             optional    the sort order (default "privacy asc")
  #  :number_to_fetch  optional    the number of records to fetch (default 10)
  #  :mode             optional    :paginated (default), :all
  #
  def self.quick_match(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    profile_type     = options[:profile_type]
    zip_code         = options[:zip_code].blank? ? nil : options[:zip_code]
    property_type    = options[:property_type].blank? ? "all" : options[:property_type]
    offset           = options[:offset].blank? ? nil : options[:offset]
    number_to_fetch  = options[:number_to_fetch].blank? ? 10 : options[:number_to_fetch]
    sort             = options[:sort].blank? ? "privacy desc" : options[:sort]
    mode             = options[:mode].blank? ? :paginated : options[:mode]
    include_inactive = options[:inactive]
    allow_duplicate_buyer_profiles = options[:allow_duplicate_buyer_profiles] || false
    results          = Array.new
    count            = 0

    monthly_pay_sort = ""
    down_pay_sort = ""

    if profile_type.owner? || profile_type.seller_agent?
      if allow_duplicate_buyer_profiles
        # #544 - go ahead and let the duplicate buyer profiles for a given user show up in the results
        template = "is_owner = false && status= 'active' && ("
      else
        # filter on a user's primary buyer profile only so that a user doesn't show up multiple times to an owner search - #544
        template = "is_owner = false && status= 'active' && is_primary_profile = true && ("
      end
    else
      template = "is_owner = true && status= 'active' && (profiles.deleted_at IS NULL OR profiles.deleted_at > '#{Time.now.utc.strftime('%Y-%m-%d %H:%M:%S')}') && (profiles.profile_delete_reason_id NOT IN ('other_owner','other_buyer') OR profiles.profile_delete_reason_id IS NULL) && ("
    end
    
    if zip_code.nil?
      template += "zip_code is not null"
    else
      # build zip_code criteria
      zip_code.split(",").each do |zip|
        template += " || " unless template[-1..-1] == "("
        template += "zip_code = " + zip
      end
    end

    template += ")"
    template += " && users.activation_code is null" unless include_inactive
    conditions = [ template ]

    if !property_type.nil? and property_type != "all"
      conditions[0] += " && property_type = ? "
      conditions.push(property_type)
    end

    if profile_type.owner? or profile_type.seller_agent? 
      mon_pay_str = "max_mon_pay"
      dow_pay_str = "max_dow_pay"
      search_profile_type = "buyer"
    else
      mon_pay_str = "min_mon_pay"
      dow_pay_str = "min_dow_pay"
      search_profile_type = "property"
    end

    # add additional conditions when search critiria given
    if filter_results = options[:filter_results]
      country     = filter_results.country
      monthly_max = filter_results.monthly_max
      down_max    = filter_results.down_max
      monthly_min = filter_results.monthly_min
      down_min    = filter_results.down_min
      keyword     = filter_results.keywords
      city        = filter_results.city
      mc_zip_code = get_mc_zip_code(filter_results)

      if !country.blank?
        conditions[0] += " && profiles.country = ? "
        conditions.push(country)
      end
      
      if !monthly_min.blank?
        conditions[0] += " && (#{mon_pay_str} >= ?) "
        conditions.push(monthly_min) 
        monthly_pay_sort = ", #{mon_pay_str} desc"
      end

      if !monthly_max.blank?
        conditions[0] += " && (#{mon_pay_str} <= ?) "
        conditions.push(monthly_max)
        monthly_pay_sort = ", #{mon_pay_str} desc"
      end
      
      if !down_max.blank?
        conditions[0] += " && (#{dow_pay_str} <= ?) "
        conditions.push(down_max)
        down_pay_sort = ", #{dow_pay_str} desc"
      end
      
      if !down_min.blank?
        conditions[0] += " && (#{dow_pay_str} >= ?) "
        conditions.push(down_min)
        down_pay_sort = ", #{dow_pay_str} desc"
      end

      if !mc_zip_code.blank?
        conditions[0] += " && (zip_code in (?)) "
        conditions.push(mc_zip_code) 
      end
      
      if !keyword.blank? || !city.blank?
        query_string = ""
        query_string = keyword unless keyword.blank?
        search_owner = search_profile_type == "property"
        search_buyer = search_profile_type == "buyer"
        query_string = "(profile_type:owner) " + query_string if search_owner && ! query_string.match(/^profile_type:/)
        query_string = "(profile_type:buyer) " + query_string if search_buyer && ! query_string.match(/^profile_type:/)
        query_string = "(property_type:" + property_type + ") " + query_string if (property_type && property_type != 'all')
        query_string += "(profile_city:" + city + ") " unless city.blank?
        
        search = ActsAsXapian::Search.new([Profile], query_string, {:limit => 10000000})
        keyword_profiles = []
        search.results.each { |result|
          keyword_profiles << result[:model].id
        }
        
        if !keyword_profiles.empty?
          conditions[0] += " && profile_field_engine_indices.profile_id IN (?)"
          conditions.push(keyword_profiles)
        end
      end
    end

    # (from Ticket #330 )
    # Buyers list should be sorted when filtering results on the basis of monthly payment, down payment are given
    sort << "#{monthly_pay_sort}#{down_pay_sort}"
    
    # (from Ticket #322)
    # Buyers should be reported this way:
    # - Buyers are reported once for every 'property type' profile no matter
    #   how many zip codes are associated with any one profile
    # - Buyers with more than 1 profile for the same property type
    #   (for example 3 profiles for single family) will still report once in the system.
    #
    # Example 1: damon has a SF profile (3 zips), MF profile (5 zips), and an Acreage profile (10 zips) = report as 3 buyers
    #
    # Example 2: damon has a SF profile (3 zips), MF profile (5 zips), and an Acreage profile (10 zips)
    #            and 2 more SF profiles (any number of zips) = report as 3 buyers
    #
    #
    # Note from James: since profiles may only belong to one property type, this shouldn't be an issue. However, I'm adding
    # grouping with the property type into the SQL to handle any future change in this regard. I'm also disregarding example 2's
    # concept of "2 more SF profiles", since that would involve finding unique profiles for a user account, which in the past was
    # never desired. May have to change this in the future if Damon changes his mind on how multiple profiles for a user works.
    #

    # Set limit and offset if we are not asking for all of them
    
    limit_and_sort_hash = (mode == :paginated) ? { :limit => number_to_fetch, :offset => offset, :order => "#{sort}, property_type_sort_order asc" } : { }

    # 1. get all buyer profiles
    all_matches = ProfileFieldEngineIndex.find(:all, { :select => "distinct profile_field_engine_indices.id, profile_field_engine_indices.profile_id, profile_field_engine_indices.property_type", :joins =>[:profile => :user], :include => [:profile], :conditions => conditions, :group => "profile_field_engine_indices.profile_id, profile_field_engine_indices.property_type" }.merge(limit_and_sort_hash))

    total_matches = ProfileFieldEngineIndex.count('profile_field_engine_indices.id', :include => [:profile], :joins => [:profile => :user], :conditions => conditions, :group => "profile_field_engine_indices.profile_id").length

    # 2. find the unique list of buyers profiles for each property type
    # unique_profile_ids = all_matches.collect { |index| index.profile_id }

    # 3. return the final profile objects, along with the appropriate pagination/total counts necessary for the UI

    # JWH: Optimized on 5/20/2008 - faster if the profile_fields are loaded separately than using eager loading
    #      (generates too many rows and slow with the outer join), plus the sort order is screwed up if an IN clause
    #      is used.
    #
    #      Also, eager loading :profile_images doesn't impact performance but breaks some of the zip_code_map logic
    #      (I'm thinking that the acts_as_attachment doesn't get setup properly if eager loaded this way)

    ids = all_matches.map{|x| x.profile_id}
    results = Profile.find(:all, :conditions => ["id IN (?)", ids], :include => [:profile_type])

    count = total_matches
    total_pages = (count / number_to_fetch)
    total_pages += 1 if (count % number_to_fetch) != 0
    total_pages = 1 if total_pages == 0

    total_pages = (count / number_to_fetch)
    total_pages += 1 if (count % number_to_fetch) != 0
    total_pages = 1 if total_pages == 0

    return results, count, total_pages
  end

  def self.get_mc_zip_code(filter_results)
    # fetch mc_zip_code only when user given search criteria
    if !filter_results.state_name.blank?
      if filter_results.territory_name.empty?
        mc_zip_code = Zip.get_zips_for_state_on_preview(filter_results.state_name, filter_results.country) 
      else
        mc_zip_code = Zip.get_zips_for_territory_on_preview(filter_results.territory_name, filter_results.country)
      end
    elsif filter_results.country == "CA" &&  !filter_results.territory_name.blank?
      mc_zip_code = Zip.get_zips_for_territory_on_preview(filter_results.territory_name, filter_results.country)
    end
    mc_zip_code.push(0) if mc_zip_code && mc_zip_code.empty?
    mc_zip_code
  end

  #
  # Returns an array of Profiles that match for a given profile
  #
  # Arguments:
  #
  #  :profile          required    Profile to find matches for
  #  :use_cache        optional    true (default) to support using cached results, or false to skip cache and force a recalc
  #  :mode             optional    :paginated (default), :all, :count (where matching profile instances are not needed),
  #                                or :ids (for the profile_ids only - doesn't fetch profile instances)
  #  :result_filter    optional    The result filter for getting matches :all (default), :new, :viewed_me, :favorites
  #                                (supports tabbing in the UI or profile messaging), :new_email (uses last_login
  #                                instead of previous_login used by the UI)
  #  :offset           optional    the starting index of the results to return (default start with the first)
  #  :number_to_fetch  optional    the number of records to fetch (default 10)
  #
  def self.get_matches(*args)     
    options           = args.last.is_a?(Hash) ? args.pop : {}
    profile           = options[:profile]
    offset            = options[:offset].blank? ? nil : options[:offset]
    number_to_fetch   = options[:number_to_fetch].blank? ? 10 : options[:number_to_fetch]
    result_filter     = options[:result_filter].blank? ? :all : options[:result_filter]
    mode              = options[:mode].blank? ? :paginated : options[:mode]
    sort              = options[:sort].blank? ? "privacy desc" : options[:sort]
    listing_type      = options[:listing_type].blank? ? :all : options[:listing_type]
    include_inactive  = options[:inactive]
    created_date     =  options[:created_date]
    from_date         =  options[:from_date]
    to_date            =  options[:to_date]
    results           = Array.new
    count             = 0
    previous_login_at = nil
    join_clause       = nil
    use_cache         = options[:use_cache].blank? ? false : options[:use_cache]
    near_match        = options[:near_match].blank? ? false : options[:near_match]

    # Set limit and offset if we are not asking for all of them
    limit_and_sort_hash = (mode == :paginated or mode == :ids) ? { :limit=>number_to_fetch, :offset=>offset,:order=>"#{sort}, property_type_sort_order asc" } : { }
    limit_hash = (mode == :paginated or mode == :ids) ? { :limit=>number_to_fetch, :offset=>offset } : { }
    sort_hash = (mode == :paginated or mode == :ids) ? { :order=>"#{sort}, property_type_sort_order asc" } : { }

    if listing_type == 'fsbo'
      listing_where = " profiles.profile_type_id = '#{ProfileType.get_guid('owner')}' "
    elsif listing_type == 'listed'
      listing_where = " profiles.profile_type_id = '#{ProfileType.get_guid('seller_agent')}' "
    elsif listing_type == 'buyer'
      listing_where = " profiles.profile_type_id = '#{ProfileType.get_guid('buyer')}' "
    elsif listing_type == 'buyer_agent'
      listing_where = " profiles.profile_type_id = '#{ProfileType.get_guid('buyer_agent')}' "
    end
    
    # special case: favorites
    if result_filter == :favorites || result_filter == 'favorites' then
      
    
      where = "profile_favorites.profile_id = ?"
      where += " && ((is_near is false) or (is_near is null))"
      where += " and users.activation_code is null" unless include_inactive
      where += " && " + listing_where unless listing_where.nil?
      
      conditions = [ where, profile.id ]
      if !include_inactive
        user_join = [:target_profile=>:user]
      elsif listing_where
        user_join = [:target_profile]
      end
      
      count = ProfileFavorite.count( :all, :select => "DISTINCT target_profile_id", :conditions => conditions, :joins=>user_join)
      return count if(mode == :count) # support rapid query for getting the # of favorites
      matches = ProfileFavorite.find( :all, { :select => "DISTINCT target_profile_id", :conditions => conditions, :joins=>user_join}.merge(limit_hash) )

      matches.each do |match|
        if (mode == :ids || mode == "ids")
          results << match.target_profile.id
        else
          results << match.target_profile
        end
      end
      
      unless number_to_fetch == 0
        total_pages = (count / number_to_fetch)
        total_pages += 1 if (count % number_to_fetch) != 0
        total_pages = 1 if total_pages == 0
      else
        total_pages = 1
      end

      return results, count, total_pages
    end

    # special case: viewed_me
    if result_filter == :viewed_me || result_filter == 'viewed_me' then
      # Nobody who is inactive should have been able to view me so no point in filtering inactive users out for this one
      where = "profile_views.profile_id = ?"
      where += " && " + listing_where unless listing_where.nil?

      if listing_where
        join = [:viewed_by_profile]
      end
        
      count = ProfileView.count( :all, :select => "DISTINCT viewed_by_profile_id", :conditions => [where , profile.id ], :joins=>join)
      return count if(mode == :count) # support rapid query for getting the count only
      matches = ProfileView.find( :all,{ :select => "DISTINCT viewed_by_profile_id", :joins=>join, :conditions => [ where, profile.id ]}.merge(limit_hash))

      matches.each do |match|
        if (mode == :ids)
          results << match.viewed_by_profile.id
        else
          results << match.viewed_by_profile
        end
      end
    unless number_to_fetch == 0
      total_pages = (count / number_to_fetch)
      total_pages += 1 if (count % number_to_fetch) != 0
      total_pages = 1 if total_pages == 0
    else
      total_pages = 1
    end
      
      return results, count, total_pages
    end

    # check if only interested in profiles that have changed since previous login (for UI purposes)
    if result_filter == :new || result_filter == 'new' then
      user = User.find( profile.user_id ) unless profile.user_id == nil
      previous_login_at = user.previous_login_at unless user == nil
    end

    # check if only interested in profiles that have changed since last login (for email purposes)
    if result_filter == :new_email || result_filter == 'new_email' then
      user = User.find( profile.user_id ) unless profile.user_id == nil
      previous_login_at = user.last_login_at unless user == nil
    end
    if use_cache
      template = "( zip_code is not null)"
    end
    if !use_cache
      targets = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    # safety valve: should always find at least one zip_code (self)
    return [], 0, "" if targets.size == 0
    
    # build zip_code portion of query template
    template = "("

    # build zip_code criteria
    targets.each do |target|
      if target.is_owner
        template += " || " unless template == "("
        template += "zip_code = " + "'" + target.zip_code + "'"
        zip_record = Zip.find(:first, :conditions => ["zip = ?",target.zip_code])
        unless zip_record.county_id.blank?
          county_record = County.find(zip_record.county_id)
          template += " || "
          template += "county = " + "'" + county_record.name + "'"
        end 
      else
        if target.county.blank?
          template += " || " unless template == "("
          template += "zip_code = " + "'" + target.zip_code + "'"
        else
          buyer_county = County.find(:first, :conditions => ["name = ?",target.county])
          buyer_zips = Zip.find(:all,:conditions => ["county_id = ?",buyer_county.id])
          unless buyer_zips.blank?
            zips_array = buyer_zips.map(&:zip)
            zips_string = String.new
            zips_array.each do |zip|
              zips_string = "'"+zip+"'" and next if zips_string.blank?
              zips_string = zips_string.to_s+","+"'"+zip.to_s+"'"
            end
             template += " || " unless template == "("
             template += "zip_code in " + "(" + zips_string + ")"
          end
        end
      end
    end

    target = targets.first
    sfmfct = target.property_type == 'single_family' || target.property_type == 'multi_family' || target.property_type == 'condo_townhome'
    vlacot = target.property_type=='other' || target.property_type=='vacant_lot' || target.property_type=='acreage'
    # build rest of where clause
    if target.is_owner then      
      template += ") && (is_owner = false) && (property_type = ?) && (status = 'active')"
#      template += " && (beds <= ?) && (baths <= ?) && (square_feet_min <= ?) && (min_mon_pay <= ?) && (min_dow_pay <= ?)" if sfmfct
      template += " && (beds <= #{target.beds}) && (baths <= #{target.baths})" if target.property_type == 'single_family' || target.property_type == 'condo_townhome'

      template += " && (square_feet_min <= ?) && (square_feet_max >= ?)" if sfmfct

      template += " && (max_mon_pay >= #{target.min_mon_pay}) && (max_dow_pay >= #{target.min_dow_pay})" if sfmfct and (profile.is_owner_finance_profile? or profile.is_wholesale_owner_finance_profile?)

      template += " && (profiles.investment_type_id = #{profile.investment_type_id})"

      target_sqft = target.square_feet

      if target.price > 0 then
        template += " && (price_max = 0 || (price_min <= " + target.price.to_s + " && " + target.price.to_s + " <= price_max))"
      end

      if target.price > 0 then
        template += " && (" + target.price.to_s + " <= max_purchase_value)" if (profile.is_wholesale_profile? or profile.is_wholesale_owner_finance_profile?)
      end

      if target.after_repair_value > 0 then
        template += " && (arv_repairs_value =  round(((#{target.price} + #{target.total_repair_needed})/(#{target.after_repair_value}))*(#{100})))" if (profile.is_wholesale_profile? or profile.is_wholesale_owner_finance_profile?)
      end

      template += " && (units_max = 0 || (units_min <= " + target.units.to_s + " && " + target.units.to_s + " <= units_max))" if target.property_type == 'multi_family'
#       template += " && (acres_min <= " + target.acres.to_s + ") " if target.property_type == 'acreage'
      template += " && (acres_min <= " + target.acres.to_s + " && acres_max >= " + target.acres.to_s + ")" if target.property_type == 'acreage'
      template += " && (max_mon_pay >= #{target.min_mon_pay}) && (max_dow_pay >= #{target.min_dow_pay})" if vlacot and (profile.is_owner_finance_profile? or profile.is_wholesale_owner_finance_profile?)
    else
      template += ") && (is_owner = true) && (property_type = ?)  && status='active'"
      template += " && (beds >= #{target.beds}) && (baths >= #{target.baths})" if target.property_type == 'single_family' || target.property_type == 'condo_townhome'
      template += " && (square_feet BETWEEN ? AND ? )" if sfmfct
      template += " && (min_mon_pay <= #{target.max_mon_pay}) && (min_dow_pay <= #{target.max_dow_pay})" if sfmfct and ( profile.is_owner_finance_profile? or profile.is_wholesale_owner_finance_profile? )

      template += " && (profiles.investment_type_id = #{profile.investment_type_id})"

      target_sqft = target.square_feet_min

      if target.max_purchase_value > 0 then
        template += " && (price <= " + target.max_purchase_value.to_s + ")" if (profile.is_wholesale_profile? or profile.is_wholesale_owner_finance_profile?)
      end

      if target.arv_repairs_value > 0 then
        template += " && ( #{target.arv_repairs_value} = round(((price + total_repair_needed)/(after_repair_value))*(100)))" if (profile.is_wholesale_profile? or profile.is_wholesale_owner_finance_profile?)
      end

      if target.price_max > 0 then
        template += " && (price = 0 || (" + target.price_min.to_s + " <= price && price <= " + target.price_max.to_s + "))"
      end

      template += " && (" + target.units_min.to_s + " <= units && units <= " + target.units_max.to_s + ")" if target.property_type == 'multi_family'
#       template += " && (acres >= " + target.acres_min.to_s + ")" if target.property_type == 'acreage'
      template += " && (acres >= " + target.acres_min.to_s + " && acres <= " + target.acres_max.to_s + ")" if target.property_type == 'acreage'
      template += " && (min_mon_pay <= #{target.max_mon_pay}) && (min_dow_pay <= #{target.max_dow_pay})" if vlacot and (profile.is_owner_finance_profile? or profile.is_wholesale_owner_finance_profile?)
    end
    end
    # add optional join to restrict to newly modified profiles (since previous login)
    unless previous_login_at == nil
      template += " && (profiles.created_at > '" + previous_login_at.strftime("%Y-%m-%d %H:%M:%S") + "')"
      join_clause = "INNER JOIN profiles ON profiles.id = profile_field_engine_indices.profile_id"
    end
  
    unless include_inactive
      template += " && (users.activation_code is null) "
      join_clause = "INNER JOIN profiles ON profiles.id = profile_field_engine_indices.profile_id" if join_clause.nil?
      join_clause += " INNER JOIN users ON users.id = profiles.user_id "
      if created_date.is_a?(Date)  # This is for cron job of daily buyer responder email
          creation_date_of_profile = profile.created_at.to_date.to_s(:db) if profile.created_at.is_a?(Time)
          unless creation_date_of_profile.blank?
             join_clause += " and ( date(profiles.created_at) = '#{created_date}' or date(profiles.updated_at) ='#{created_date}' or date(profiles.deleted_at) =  '#{created_date + 11 }'  )  " if !(creation_date_of_profile == created_date.to_s(:db)) 
          end
      end
      join_clause += " and date(profile_created_at) <= '#{to_date}'" if !from_date.nil? and !to_date.nil?
    end

    template += " && " + listing_where unless listing_where.nil?
    if use_cache
      pmc = ProfileMatchesCount.find_by_profile_id(profile.id)
      if pmc.nil? || pmc.count < 0
        pmc = ProfileMatchesCount.create(:profile_id => profile.id, :count => 0) if pmc.nil?
        pmc.update_attribute(:count, 0)
        ProfileMatchesDetail.save_profile_matches_data(profile)
      end
       targets = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ])
      target = targets.first
      template += " && profile_id in (?) "
      template += " && profiles.deleted_at is null "
      count = 0
      if near_match
        profile_matches = ProfileMatchesDetail.near_match_exists?(profile)
      else
        profile_matches = ProfileMatchesDetail.exact_match_exists?(profile)
      end
      if profile_matches.nil? or profile_matches.empty?
        count = 0
        profile_matches_ids = "empty"
        return count if(mode == :count) # support rapid query for getting the count only
      else
        profile_matches_ids = Array.new
        profile_matches.each do |pm|
          if pm.source_profile_id == profile.id
            profile_matches_ids.push(pm.target_profile_id)
          else
            profile_matches_ids.push(pm.source_profile_id)
          end
        end
        count = ProfileFieldEngineIndex.count( :all,  :conditions => [ template, profile_matches_ids], :joins => join_clause, :group => "profile_field_engine_indices.profile_id" ).length
        return count if(mode == :count) # support rapid query for getting the count only          
      end
      if near_match
        matches = ProfileFieldEngineIndex.find( :all, { :conditions => [ template, profile_matches_ids], :joins => join_clause, :order=>"profile_field_engine_indices.id", :group => "profile_field_engine_indices.profile_id" }.merge(sort_hash))
        matches = matches[offset.to_i,number_to_fetch.to_i]
      else
        matches = ProfileFieldEngineIndex.find( :all, { :conditions => [ template, profile_matches_ids], :joins => join_clause, :order=>"profile_field_engine_indices.id", :group => "profile_field_engine_indices.profile_id" }.merge(limit_and_sort_hash) )
      end
    else
    if sfmfct then
      count = ProfileFieldEngineIndex.count( :all, :conditions => [ template, target.property_type, target_sqft, target_sqft], :joins => join_clause ) if target.is_owner
      count = ProfileFieldEngineIndex.count( :all, :conditions => [ template, target.property_type, target_sqft, target.square_feet_max], :joins => join_clause ) if !target.is_owner
      return count if(mode == :count) # support rapid query for getting the count only
      matches = ProfileFieldEngineIndex.find( :all, { :conditions => [ template, target.property_type, target_sqft, target_sqft], :joins => join_clause, :order=>"profile_field_engine_indices.id" }.merge(sort_hash) ) if target.is_owner
      matches = ProfileFieldEngineIndex.find( :all, { :conditions => [ template, target.property_type, target_sqft, target.square_feet_max], :joins => join_clause, :order=>"profile_field_engine_indices.id" }.merge(sort_hash) ) if !target.is_owner
    else
      count = ProfileFieldEngineIndex.count( :all, :conditions => [ template, target.property_type], :joins => join_clause ) if target.is_owner
      count = ProfileFieldEngineIndex.count( :all, :conditions => [ template, target.property_type], :joins => join_clause ) if !target.is_owner
      return count if(mode == :count)  # support rapid query for getting the count only
      matches = ProfileFieldEngineIndex.find( :all, { :conditions => [ template, target.property_type], :joins => join_clause, :order=>"profile_field_engine_indices.id"}.merge(sort_hash) ) if target.is_owner
      matches = ProfileFieldEngineIndex.find( :all, { :conditions => [ template, target.property_type], :joins => join_clause, :order=>"profile_field_engine_indices.id"}.merge(sort_hash) ) if !target.is_owner
    end
    end

    unless number_to_fetch == 0
    total_pages = (count / number_to_fetch)
    total_pages += 1 if (count % number_to_fetch) != 0
    total_pages = 1 if total_pages == 0
    else
      total_pages = 1
    end

    if mode == :ids
      unless matches.nil?
        profile_ids = matches.collect { |match| match.profile_id if !match.profile.nil? }
        return profile_ids, count, total_pages
      end
    end

    matches.each do |match|
      # optimization note: cannot replace with IN clause as we can't guarantee the order of the profiles returned,
      # which will mess up the sorting and create random order changes during pagination
      results << match.profile if !match.profile.nil?
    end

    return results, count, total_pages
  end

  # From: Blue Jazz Consulting utility library
  #
  # Returns a hash whose keys correspond to the unique return values from evaluating the condition symbol
  # and whose values are arrays containing the elements that match the keys. If the condition results in a
  # nil value, the element is ignored
  #
  # This is commonly needed when an array of models need to be grouped by a user, status, or some other
  # property and treated as a "hashed-array"
  #
  # Examples:
  #
  #   Using a Symbol:
  #
  #   >> a = ["1","2","3","1"] # Hashcodes are 50,51,52,50 respectively
  #   >> a.hashed_by :hash
  #   => {50=>["1", "1"], 51=>["2"], 52=>["3"]}
  #
  #   Using a Block:
  #
  #   >> a = ["1","2","3","1"]
  #   >> a.hashed_by { |element| element.to_s }
  #   => {"1"=>["1", "1"], "2"=>["2"], "3"=>["3"]}
  #
  def self.hash_by(elements,condition=nil)
    hash = Hash.new

    elements.each do |element|
      # TODO: Add support for strings
      key = nil
      case condition
        when Symbol: key = element.send(condition)
        when nil: key = yield element if block_given?
      end

      if key
        if !hash[key]
          hash[key] = Array.new
        end
        hash[key] << element
      end
    end

    return hash
  end

  #
  # Returns count of buyer profiles that matches given a short list of matching criteria
  #
  # Arguments:
  #
  #  :zip_code         required    the zipcode to match
  #  :beds             required
  #  :bath             required

  def self.buyer_matches lead
    query_str_proc = proc{|attr, value, query_str|
      query_str += ' AND ' unless query_str.blank?
      query_str += "#{attr}:#{value}"
    }

    baths_mapping = {
     1 => [1],
     2 => [1, 3],
     3 => [1, 3, 5]
    }

    zip = Zip.find_by_zip(lead.zip_code)
    zip_code = zip.territory.zips.map{|x| x.zip}.join(' OR ') if zip
    
    baths_str = if baths_mapping[lead.baths]
      (baths_mapping[lead.baths] << 0).join(' OR ')
    else
      [1, 3, 5, 7, 0].join(' OR ')
    end

    beds = (1..lead.beds).map{|x| x} << 0

    query_str = "profile_type:ce5c2320-4131-11dc-b431-009096fa4c28"
    query_str = query_str_proc["beds", "(#{beds.join(' OR ')})", query_str]
    query_str = query_str_proc["baths", "(#{baths_str})", query_str]
    query_str = query_str_proc["zip", "(#{zip_code})" || lead.zip_code, query_str]
    
    results = ActsAsXapian::Search.new([ProfileFieldEngineIndex], query_str, :limit => 10000).results.map{|x| x[:model]}.compact

    return 0 if results.blank?
    results.group_by(&:profile_id).count
  end
end
