# LATLNG
require 'net/http'

include ActionController::UrlWriter

class ZipCodeMap

  def self.prepare_map_params(zip_codes = "78701", options = {})
    map_params = Hash.new
    map_params[:map_type_init] = options[ :map_type_init ] || GMapType::G_NORMAL_MAP
    map_params[:click_route] = options[ :click_route ] || nil
    map_params[:zipcodes_js_source] = options[ :zipcodes_js_source ] || 'zip_selection_controller.zipcodes'
    map_params[:zoom_level] = options[ :zoom_level ] || 11
    map_params[:center_latlng] = options[ :center_latlng ] || nil
    map_params[:default_zip] = options[ :default_zip ] || "78701"

    first_zip = zip_codes.split(/[^0-9]+/).first
    map_params[:zip] = Zip.find_by_zip(first_zip) unless first_zip.nil?
    map_params
  end

  def self.prepare_map(zip_codes = "78701", options = {})
    map_type_init = options[ :map_type_init ] || GMapType::G_NORMAL_MAP
    suppress_controls = options[ :suppress_controls ] || nil

    click_route = options[ :click_route ] || nil
    zipcodes_js_source = options[ :zipcodes_js_source ] || 'zip_selection_controller.zipcodes'

    zoom_level = options[ :zoom_level ] || 11
    center_latlng = options[ :center_latlng ] || nil
    default_zip = options[ :default_zip ] || "78701"

#     first_zip = zip_codes.split(/[^0-9]+/).first
    first_zip = zip_codes.split(",").first
    zip = Zip.find_by_zip(first_zip) if ! first_zip.nil?

    map = GMap.new("preview_results_map_div") if click_route
    map = GMap.new("preview_results_map_div", "move") unless click_route

    map.set_map_type_init(map_type_init)
    map.control_init(:small_map => true, :map_type => true, :scale => true) unless suppress_controls == true

    # create client-side map click event handler
    if click_route then
      js  =  "function(overlay,point)"
      js +=  "{"
      js +=    "if(point){"
      js +=      "new Ajax.Request('#{click_route}', { asynchronous:true, evalScripts:true, parameters:'lat='+point.y+'&long='+point.x+'&zipcodes='+#{zipcodes_js_source}});"
      js +=    "}"
      js +=    "return false;"
      js +=  "}"

      map.event_init(map,:click,js)
    end

    if center_latlng == nil then
      if zip.nil? then
        # if they managed to leave it blank or they entered a zip that's not in our zcta data
        # reverse geocode to show the zip
        first_zip = first_zip || default_zip
        js = "new GClientGeocoder().getLatLng(\"#{first_zip}\", function(gLatLng) { map.setCenter(gLatLng); map.setZoom(10); });"
        map.record_init(js)
      else
        begin
          zcta = zip.zctas.first.latlongs.first
          map.center_zoom_init([ zcta.lat, zcta.lng ],zoom_level)
        rescue
          # We have the zip, but not the zcta data
          map.center_zoom_init([ zip.lat, zip.lng ],4)
        end
      end
    else
      lat = center_latlng.split(/,\s*/).first
      lng = center_latlng.split(/,\s*/).last

      map.center_zoom_init([lat,lng],zoom_level)
    end

    map
  end

  def self.prepare_map_overlay_click_event_handler(click_route, options = {})
    zipcodes_js_source = options[ :zipcodes_js_source ] || 'zip_selection_controller.zipcodes'

    js  =  "function(latlng)"
    js +=  "{"
    js +=    "new Ajax.Request('#{click_route}', { asynchronous:true, evalScripts:true, parameters:'lat='+latlng.y+'&long='+latlng.x+'&zipcodes='+#{zipcodes_js_source}});"
    js +=    "return false;"
    js +=  "}"

    js
  end

  def self.prepare_boundary_overlays( zip_codes )
    zip_color = '#888888'
    zip_opacity = 0.85

    zip_fill_color = '#CC6600'
    zip_fill_opacity = 0.25

    zips = []

    zip_codes.split(/[^0-9]+/).each do |zipcode|
      zips << Zip.find_by_zip(zipcode)
    end

    overlays = []

    # TODO: optimize this block (raw SQL? in clause? :include in the finder above?)
    zips.each do |z|
      begin
        z.zctas.each do |zcta|
          zip_boundary = []

          zcta.latlongs.each_with_index { |x,n| ( zip_boundary << [ x.lat, x.lng ] ) unless n == 0 }

          overlays << GPolygon.new(zip_boundary, zip_color, 4, zip_opacity, zip_fill_color, zip_fill_opacity)

          # overlays << encoded_polyline = GPolylineEncoded.new( :points => zcta.points, :levels => zcta.levels, :color => zip_color, :weight => 4, :opacity => zip_opacity )
          # overlays << GPolygonEncoded.new(encoded_polyline,true,zip_fill_color,zip_fill_opacity)
        end
      rescue
        puts "el problemo finding latlongs for zcta " + z.zctas.first.zcta.to_s unless z == nil
      end
    end

    overlays
  end

  def self.prepare_boundary_latlngs( zip_codes )
    zip_color = '#888888'
    zip_opacity = 0.85
    
    zip_fill_color = '#CC6600'
    zip_fill_opacity = 0.25
    
    zips = []

    zip_codes.split(/[^0-9]+/).each do |zipcode|
      zips << Zip.find_by_zip(zipcode)
    end

    # TODO: optimize this block (raw SQL? in clause? :include in the finder above?)
    overlays = {}
    zips.each do |z|
      zip_boundary = []
      begin
        z.zctas.each do |zcta|
          zcta.latlongs.each_with_index { |x,n| ( zip_boundary << [ x.lat, x.lng ] ) unless n == 0 }
        end
        overlays[z] = zip_boundary
      rescue
        puts "el problemo finding latlongs for zcta " + z.zctas.first.zcta.to_s unless z == nil
      end
    end
    overlays
  end

  def self.prepare_marker_overlays( profiles, options = {} )
    include_private = options[ :include_private ] || true
    context_profile = options[ :context_profile ] || nil
    return_params = options[ :return_params ] || nil
    use_numbered_icons = options[ :use_numbered_icons ] || false
    overlays = []

    profiles.each_with_index do |profile, index|
      next if profile.buyer?

      begin
        icon = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/"+get_icon_path(profile.property_type, profile.display_privacy.downcase, index+1) ) if use_numbered_icons
        icon = get_icon(profile.property_type, profile.display_privacy.downcase.to_sym) unless use_numbered_icons

        # TODO: optimize this block or the caller's list of profiles to include zips?

        if profile.country == "CA"
          zcta = Zip.find(:first, :conditions => [" zip = ?",profile.zip_code])
        else
          zcta = Zip.find_by_zip(profile.zip_code.split(/[^0-9]+/).first).zctas.first.latlongs.first
        end

        if profile.public_profile? then
          if profile.geocoder_address == nil then
            overlays << GMarker.new( [ zcta.lat + rand / 100 - 0.005, zcta.lng + rand / 100 - 0.005 ], :title => profile.name, :info_window => info_window( profile, context_profile, return_params ), :icon => icon )
          elsif return_params == nil
            # LATLNG
            # overlays << GMarker.new( profile.latlng, :title => profile.name, :icon => icon )
            overlays << GMarker.new( profile.geocoder_address, :title => profile.name, :icon => icon )
          else
            # LATLNG
            # overlays << GMarker.new( profile.latlng, :title => profile.name, :info_window => info_window( profile, context_profile, return_params ), :icon => icon )
            overlays << GMarker.new( profile.geocoder_address, :title => profile.name, :info_window => info_window( profile, context_profile, return_params ), :icon => icon )
          end
        elsif include_private == true then
          if return_params == nil
            overlays << GMarker.new( [ zcta.lat + rand / 100 - 0.005, zcta.lng + rand / 100 - 0.005 ], :title => profile.name, :icon => icon )
          else
            overlays << GMarker.new( [ zcta.lat + rand / 100 - 0.005, zcta.lng + rand / 100 - 0.005 ], :title => profile.name, :info_window => info_window( profile, context_profile, return_params ), :icon => icon )
          end
        end
      rescue
        # puts "el problemo finding zip when preparing markers: " + profile.zip_code
      end
    end unless profiles == nil

    overlays
  end

  def self.info_window( profile, context_profile = nil, return_params = nil )
    # construct path to photo
    photo_path = "/images/missing.gif"

    unless( profile.profile_images == nil || profile.profile_images.first == nil || profile.profile_images.first.public_filename == nil )
      if( profile.profile_images.first.thumbnail? )
        photo_path = profile.profile_images.first.thumbnail.public_filename
      else
        photo_path = profile.profile_images.first.public_filename
      end
    end

    # construct url for link to profile
    profile_url = "#"
    if( context_profile == nil )
      profile_url = "/home/preview_owner/#{profile.id}"
      profile_url += '?type=buyer' 
      profile_url += '&' + return_params unless return_params == nil
    elsif context_profile == 'search'
      profile_url = "/search/preview_owner/#{profile.id}?ref=search"
      profile_url += '&' + return_params unless return_params.nil?
    else
      profile_url = profile_profile_view_path( context_profile, profile )
      profile_url += '?' + return_params unless return_params == nil
    end
    

    html  = '<div style="width:210px; height:100px; color:#333333; text-align:center;">'
    html +=   '<table width="100%" style="font-size:9pt; line-height:12pt; padding-left:10px;">'
    html +=     '<tr>'
    html +=       '<td colspan=2>'
    html +=         "<b>#{profile.name.to_s.gsub(/\'/, '')}</b>"
    html +=       '</td>'
    html +=     '</tr>'
    html +=     '<tr>'
    html +=       '<td>'
    html +=         '<img class="image" src="' + photo_path + '" title="Property Photo" width="60" />'
    html +=       '</td>'
    html +=       '<td style="text-align:left">'

    if( profile.property_type_single_family? )
      html +=       "#{profile.display_bedrooms}" + ' bd ' + "#{profile.display_bathrooms}" + ' ba<br>'
      html +=       "#{profile.display_square_feet}" + ' sf<br>'
      html +=       "#{profile.display_price}" + '<br>'
    elsif( profile.property_type_multi_family? )
      html +=       "#{profile.display_units}" + ' units<br>'
      html +=       "#{profile.display_price}" + '<br>'
    elsif( profile.property_type_condo_townhome? )
      html +=       "#{profile.display_bedrooms}" + ' bd ' + "#{profile.display_bathrooms}" + ' ba<br>'
      html +=       "#{profile.display_square_feet}" + ' sf<br>'
      html +=       "#{profile.display_price}" + '<br>'
    elsif( profile.property_type_vacant_lot? )
      html +=       "#{profile.display_neighborhood}" + '<br>'
      html +=       "#{profile.display_price}" + '<br>'
    elsif( profile.property_type_acreage? )
      html +=       "#{profile.display_acres}" + ' acres<br>'
      html +=       "#{profile.display_county}" + ' county<br>'
      html +=       "#{profile.display_price}" + '<br>'
    end

    html +=         '<a href="' + profile_url + '">More details...</a>'
    html +=       '</td>'
    html +=     '</tr>'
    html +=   '</table>'
    html += '</div>'

    html
  end

  def self.find_adjacent_zips( zip, ew_miles, ns_miles )
    find_adjacent_zips_for_coords( zip.lat, zip.lng, ew_miles, ns_miles )
    # find_adjacent_zips_for_coords( zip.zctas.first.latlongs.first.lat, zip.zctas.first.latlongs.first.lng, ew_miles, ns_miles )
  end

  def self.find_adjacent_zips_for_coords( lat, lng, ew_miles, ns_miles )
    begin
      lat_miles = 69.172
      lng_miles = ( lat_miles * Math.cos( lat * ( Math::PI / 180 ) ) ).abs

      lat_min = lat - ns_miles / lat_miles
      lat_max = lat + ns_miles / lat_miles

      lng_min = lng - ew_miles / lng_miles
      lng_max = lng + ew_miles / lng_miles

      # now do the lookup
      Zip.find( :all, :conditions => [ "( lat BETWEEN #{lat_min} AND #{lat_max} ) AND ( lng BETWEEN #{lng_min} AND #{lng_max} )" ] )
    rescue
      puts "el problemo finding adjacent zips"
    end
  end

  def self.find_zip_for_coords( lat, lng )
    # progressively cast a wider net
    zip = choose_zip( find_adjacent_zips_for_coords( lat, lng,  5,  5 ), lat, lng )
    zip = choose_zip( find_adjacent_zips_for_coords( lat, lng, 10, 10 ), lat, lng ) if zip == nil
    zip = choose_zip( find_adjacent_zips_for_coords( lat, lng, 20, 20 ), lat, lng ) if zip == nil

    # use something nearby
    zip = find_adjacent_zips_for_coords( lat, lng,  5,  5 ).first if zip == nil
    zip = find_adjacent_zips_for_coords( lat, lng, 10, 10 ).first if zip == nil

    zip
  end

  def self.choose_zip( zips, lat, long )
    zips.each do |z|
      z.zctas.each do |zcta|
        insidePolygon = false;
        jj = zcta.latlongs.last

        zcta.latlongs.each_with_index do |ll,n|
          unless n == 0 then
            if ( ( ( ll.lat <= lat && lat < jj.lat ) || ( jj.lat <= lat && lat < ll.lat ) ) && ( long < ( ( jj.lng - ll.lng ) * ( lat - ll.lat ) / ( jj.lat - ll.lat ) + ll.lng ) ) ) then
              insidePolygon = ! insidePolygon
            end

            jj = ll
          end
        end

        return z if insidePolygon
      end
    end

    nil
  end

  def self.lookup_latlng( geocoder_address )
    if geocoder_address == nil then return nil end

    path  = '/maps/geo'
    path += '?q=' + geocoder_address.gsub(' ','+')
    path += '&key=' + ApiKey.get

    response = Net::HTTP.get_response('maps.google.com', path)

    lnglat = response.body.slice(/-\d+\.\d+,\s*\d+\.\d+/) # google snuck in some whitespace

    # swap lnglat order (need latlng)
    return lnglat.split(',').last.strip + ',' + lnglat.split(',').first unless lnglat == nil
    return nil
  end

  def self.lookup_latlng_alt_source( geocoder_address )
    if geocoder_address == nil then return nil end

    server = XMLRPC::Client.new2('http://rpc.geocoder.us/service/xmlrpc')
    result = server.call2('geocode', geocoder_address)

    return result[1][0]['lat'].to_s + ',' + result[1][0]['long'].to_s unless result[1][0] == nil
    return nil
  end

  # icon set for push-pins
  SINGLE_FAMILY_PUBLIC_ICON   = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_public_single_family.gif" )
  SINGLE_FAMILY_PRIVATE_ICON  = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_private_single_family.gif" )
  MULTI_FAMILY_PUBLIC_ICON    = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_public_multi_family.gif" )
  MULTI_FAMILY_PRIVATE_ICON   = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_private_multi_family.gif" )
  CONDO_TOWNHOME_PUBLIC_ICON  = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_public_condo_townhome.gif" )
  CONDO_TOWNHOME_PRIVATE_ICON = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_private_condo_townhome.gif" )
  VACANT_LOT_PUBLIC_ICON      = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_public_vacant_lot.gif" )
  VACANT_LOT_PRIVATE_ICON     = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_private_vacant_lot.gif" )
  ACREAGE_PUBLIC_ICON         = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_public_acreage.gif" )
  ACREAGE_PRIVATE_ICON        = GIcon.new( :copy_base => GIcon::DEFAULT, :image => "/images/gmap/icon_private_acreage.gif" )

  def self.get_icon( property_type, visibility = :public )
    case property_type
    when "single_family"
      return SINGLE_FAMILY_PRIVATE_ICON if visibility == :private
      return SINGLE_FAMILY_PUBLIC_ICON
    when "multi_family"
      return MULTI_FAMILY_PRIVATE_ICON if visibility == :private
      return MULTI_FAMILY_PUBLIC_ICON
    when "condo_townhome"
      return CONDO_TOWNHOME_PRIVATE_ICON if visibility == :private
      return CONDO_TOWNHOME_PUBLIC_ICON
    when "vacant_lot"
      return VACANT_LOT_PRIVATE_ICON if visibility == :private
      return VACANT_LOT_PUBLIC_ICON
    when "acreage"
      return ACREAGE_PRIVATE_ICON if visibility == :private
      return ACREAGE_PUBLIC_ICON
    else
      return SINGLE_FAMILY_PRIVATE_ICON if visibility == :private
      return SINGLE_FAMILY_PUBLIC_ICON
    end
  end

  # new numbered pushpin image support
  def self.get_icon_path( property_type, visibility = :public, index=1 )
    return "gmap/pin_icons/pin_#{visibility.to_s}_#{property_type}_#{index}.gif"
  end
end
