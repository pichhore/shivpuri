module ProfileDisplayHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper

 # Returns a field's value_text (or value, if value_text is nil)
  def field_value(key)
    # TODO: may want to optimize this by caching the fields as a hash?!
    self.profile_fields.each do |field|
      return field.value_text || field.value if field.key == key.to_s
    end

    return nil
  end

  def display_field_value(key, default_value="")
    value = field_value key
    return (value.nil? or value.empty?) ? default_value : value
  end

  def display_name
    # note: the name is set during creation based on the public/private status of the profile
    return name
  end

  def display_type
    return self.profile_type.name_string
  end

  def display_type_string
    return self.profile_type.type_string
  end

  def display_privacy
    return "Public" if public_profile?
    return "Private"
  end

  def display_property_address_with_zip
    address = field_value :property_address
    zip = field_value :zip_code
    return "#{address}, #{zip}" if !address.nil? and !zip.nil? and !address.empty? and !zip.empty?
    return "#{address}" if !address.nil? and !address.empty?
    return "(Address not provided)"
  end

  def display_property_address_without_zip
    address = field_value :property_address
    return "#{address}" if !address.nil? and !address.empty?
    return "(Address not provided)"
  end

  def display_zip_code
    county = field_value :county
    zip = field_value :zip_code
    display_content = county.blank? ? zip : county
    return self.city if !self.country.blank? and self.country == "CA"
    return "#{display_content}" if !display_content.nil? and !display_content.empty?
  end

  def display_price
    price = field_value :price
    return (price.nil? or price.empty?) ? "Undisclosed" : "#{number_to_currency price.to_f, :precision => 0}"
  end

  def display_price_min
    price = field_value :price_min
    return (price.nil? or price.empty?) ? "Undisclosed" : "#{number_to_currency price.to_f, :precision => 0}"
  end

  def display_price_range
    min = display_field_value :min_price, nil
    max = display_field_value :max_price, nil
    return "Any" if(max.nil? or min.nil?)
    return "#{number_to_currency min.to_f, :precision => 0} to #{number_to_currency max.to_f, :precision => 0}"
  end

  def display_description
    description = field_value :description
    return (description.nil? or description.empty?) ? "(not provided)" : description
  end

  def display_description_longer
    return display_description.nil? ? "(not provided)" : display_description
  end

  def display_description_short
    return display_description.nil? ? "(not provided)" : rich_text_excerpt(display_description)+"..."
  end
  
  def display_embed_video
    display_field_value :embed_video
  end
  
  def display_embed_video_longer
    return display_embed_video.nil? ? "(not provided)" : display_embed_video
  end  

  def rich_text_excerpt(value, max=80)
    return value if value.blank?
    #puts "Before: *** " + value + " ***"
    idx = value.index(/<[(div)(p)(br)(ul)]/i)
    if idx == 0 
      value = value.gsub(/></, "> <").gsub(/<\/?[^>]*>/, "").gsub(/(\s)+/, '\1').gsub(/^\s*/,"").gsub(/\s*\Z/,"")[0..max]  # Strip all tags if the whole thing starts with a tag
    elsif idx.nil? or idx > max
      value = value[0..max]                         # Go up to the max
    else
      value = value[0..(idx-1)]                     # Go up to the first tag
    end
    #puts "After: *** " + value + " ***"
    value
  end
  
  def display_features
    display_field_value :feature_tags, "(not provided)"
  end
  
  def display_deal_terms
    display_field_value :deal_terms, "(not provided)"
  end

  def display_features_longer
    display = display_field_value :feature_tags
    return (display.nil? or display.empty?) ? "(not provided)" : display[0..240]+"..."
  end

  def display_features_short
    display = display_field_value :feature_tags
    return (display.nil? or display.empty?) ? "(not provided)" : display[0..80]+"..."
  end

  def display_bedrooms
    return display_field_value(:beds, "Any")
  end

  def display_notification_email
    return display_field_value :notification_email
  end

  def display_notification_phone
    return display_field_value :notification_phone
  end

  def property_bathrooms_display_hash
    return { "1"  => "1",
             "2"  => "1.5",
             "3"  => "2",
             "4"  => "2.5",
             "5"  => "3",
             #"6"  => "3 1/2",
             "7"  => "4",
             #"8"  => "4 1/2",
             "9"  => "5",
             #"10" => "5 1/2",
             "11" => "6+",
            }
  end

  def buyer_bathrooms_display_hash
    return { "1"  => "1+",
             #"2"  => "1 1/2",
             "3"  => "2+",
             #"4"  => "2 1/2",
             "5"  => "3+",
             #"6"  => "3 1/2",
             "7"  => "4+",
             #"8"  => "4 1/2",
             "9"  => "5+",
             #"10" => "5 1/2",
             "11" => "6+",
            }
  end

  def display_bathrooms
    baths_value = field_value :baths
    if self.buyer? or self.buyer_agent?
      if baths_value.nil? or baths_value.empty? or baths_value == "any"
        return "Any"
      end
      return buyer_bathrooms_display_hash[baths_value.to_s]
    else
      # property type
      return property_bathrooms_display_hash[baths_value.to_s]
    end
  end

  def display_square_feet
    return display_field_value(:square_feet, "Any") if self.buyer? or self.buyer_agent?
    return display_field_value(:square_feet, "Undisclosed")
  end

  def display_units
    display_field_value :units, "Any"
  end

  def display_square_feet_range
    min = display_field_value :square_feet_min, nil
    max = display_field_value :square_feet_max, nil
    return "Any" if(max.nil? or min.nil?)
    return "#{min} - #{max}"
  end

  def display_retail_buyer_units_range
    min = display_field_value :units_min, nil
    max = display_field_value :units_max, nil
    return "Any" if(max.nil? or min.nil?)
    return "#{min} - #{max}"
  end

  def display_retail_buyer_acres_range
    min = display_field_value :acres_min, nil
    max = display_field_value :acres_max, nil
    return "Any" if(max.nil? or min.nil?)
    return "#{min} - #{max}"
  end

  def display_neighborhood
    field_value :neighborhood
  end

  def display_price_per_square_foot
    price = field_value :price
    square_feet = field_value :square_feet
    return "" if (price.nil? or price.empty? or square_feet.nil? or square_feet.empty?)
    price = price.gsub(/,/,"")
    square_feet = square_feet.gsub(/,/,"")
    price_per = price.to_f / square_feet.to_f
    return (price.nil? or price.empty?) ? "" : "#{number_to_currency price_per, :precision => 0}"
  end

  def display_min_mon_pay
    min_mon_pay = field_value :min_mon_pay
    return (min_mon_pay.blank?) ? "" : "#{number_to_currency min_mon_pay, :precision => 0}"
  end

  def display_min_down_pay
    min_dow_pay = field_value :min_dow_pay
    return (min_dow_pay.blank?) ? "" : "#{number_to_currency min_dow_pay, :precision => 0}"
  end
  
  def display_video_tour
    display_field_value :video_tour
  end
  
  def display_acreage
    return display_acres
  end

  def display_acres
    display_field_value :acres, "Any"
  end

  def display_county
    display_field_value :county, "Any"
  end

  def display_financing
    # TODO: implement
    return "Approved"
  end

  def display_match_count_all
#    pmc = ProfileMatchesCount.find_by_profile_id(self.id)
#    if pmc.nil? || pmc.count < 0
      return self.count_all
#    else
#      return pmc.count
#    end
  end

  def display_match_count_new
    return self.count_new
  end

  def display_match_count_views
    return self.count_viewed_me
  end

  def display_message_count_new
    return self.count_messages
  end

  def display_short_name_property_type
    return "SF Home" if self.property_type_single_family?
    return "MF Property" if self.property_type_multi_family? and (self.owner? or self.seller_agent?)
    return "Multi Family" if self.property_type_multi_family? and (self.buyer? or self.buyer_agent?)
    return "MF Home" if self.property_type_multi_family? # Fallback
    return "Condo/Townhome" if self.property_type_condo_townhome?
    return "Vacant Lot" if self.property_type_vacant_lot?
    return "Acreage" if self.property_type_acreage?
    return "Other" if self.property_type_other?
    return "Any"
  end

  def display_max_mon_pay
    display_field_value :max_mon_pay
  end

  def display_max_dow_pay
    display_field_value :max_dow_pay
  end

  def display_property_type
    return "Single Family Home" if self.property_type_single_family?
    return "Multi Family Property" if self.property_type_multi_family? and (self.owner? or self.seller_agent?)
    return "Multi Family" if self.property_type_multi_family? and (self.buyer? or self.buyer_agent?)
    return "Multi Family Home" if self.property_type_multi_family? # Fallback
    return "Condo/Townhome" if self.property_type_condo_townhome?
    return "Vacant Lot" if self.property_type_vacant_lot?
    return "Acreage" if self.property_type_acreage?
    return "Other" if self.property_type_other?
    return "Any"
  end

  def return_property_type(property_type)
    return "Single Family Home" if property_type == "single_family"
    return "Multi Family Property" if property_type == "multi_family" and (self.owner? or self.seller_agent?)
    return "Multi Family" if property_type == "multi_family" and (self.buyer? or self.buyer_agent?)
    return "Multi Family Home" if property_type == "multi_family" # Fallback
    return "Condo/Townhome" if property_type == "condo_townhome"
    return "Vacant Lot" if property_type == "vacant_lot"
    return "Acreage" if property_type == "acreage"
    return "Other" if property_type == "other"
    return "Any"
  end

  def display_youve_got_name_string(format=:normal)
    prefix = (format == :bold) ? "<b>" : ""
    suffix = (format == :bold) ? "</b>" : ""
    count = self.count_all
    if(count == 0 or count > 1)
      return "#{prefix}#{count}#{suffix} #{self.profile_type.display_plural_got_name_string}"
    else
      return "#{prefix}#{count}#{suffix} #{self.profile_type.display_singular_got_name_string}"
    end
  end

  def display_match_text_string(tab_type="all")
    type_string = (self.buyer? or self.buyer_agent?) ? "Property" : "Buyer"
    types_string = (self.buyer? or self.buyer_agent?) ? "Properties" : "Buyers"
    viewing_string = (self.buyer? or self.buyer_agent?) ? "Owners" : "Buyers"
    profile_string = (self.buyer? or self.buyer_agent?) ? "Profile" : "property"

    if(tab_type == "all")
      match_text_string = "All "+type_string+" Matches"
    elsif(tab_type == "new")
      match_text_string = "New "+type_string+" Matches <span class='smaller'>(since last login)</span>"
    elsif(tab_type == "favorites")
      match_text_string = "Your Favorite "+types_string
    elsif(tab_type == "viewed_me")
      match_text_string = ""+viewing_string+" that have viewed your #{profile_string}"
    else
      match_text_string = ""
    end

    return match_text_string
  end

  def thumbnail_url(index=1)
    # optimization to prevent loading all profile images when we just want the default std thumbnail
    if index == 1 and !default_std_thumbnail_url.nil?
      return default_std_thumbnail_url
    end

    # integrate with photo upload support
    curr_index = 0
    self.profile_images.each do |profile_image|
      if profile_image.medium?
        curr_index += 1
        if(curr_index == index)
          return profile_image.property_image_filename
        end
      end
    end
    return "/images/buyer-60.jpg" if self.buyer? or self.buyer_agent?
    return "/images/property-60.jpg" if self.owner? or self.seller_agent?
    return "" # default, just in case
  end

  def thumbnail_micro_url(index=1)
    # optimization to prevent loading all profile images when we just want the default std thumbnail
    if index == 1 and !default_micro_thumbnail_url.nil?
      return default_micro_thumbnail_url
    end

    # integrate with photo upload support
    curr_index = 0
    self.profile_images.each do |profile_image|
      if profile_image.tiny?
        curr_index += 1
        if(curr_index == index)
          return profile_image.property_image_filename
        end
      end
    end
    return "/images/buyer-50.jpg" if self.buyer? or self.buyer_agent?
    return "/images/property-50.jpg" if self.owner? or self.seller_agent?
    return "" # default, just in case
  end

  def property_thumbnail_micro_url(index=1)
    # optimization to prevent loading all profile images when we just want the default std thumbnail
    if index == 1 and !default_micro_thumbnail_url.nil?
      return default_micro_thumbnail_url
    end

    # integrate with photo upload support
    curr_index = 0
    self.profile_images.each do |profile_image|
      if profile_image.tiny?
        curr_index += 1
        if(curr_index == index)
          return profile_image.property_image_filename
        end
      end
    end
    return false
  end

  def photo_fullsize_url(index=1)
    # optimization to prevent loading all profile images when we just want the default std thumbnail
    if index == 1 and !default_photo_url.nil?
      return default_photo_url
    end

    # integrate with photo upload support
    curr_index = 0
    self.profile_images.each do |profile_image|
      if profile_image.large?
        curr_index += 1
        if(curr_index == index)
          return profile_image.property_image_filename
        end
      end
    end
    return "/images/buyer-170.jpg" if self.buyer? || self.buyer_agent?
    return "/images/property-170.jpg" if self.owner? || self.seller_agent?
    return "" # default, just in case
  end

  def photo_bigsize_url(index=1)
    # optimization to prevent loading all profile images when we just want the default std thumbnail
    if index == 1 and !default_photo_url.nil?
      return default_photo_url
    end

    # integrate with photo upload support
    curr_index = 0
    self.profile_images.each do |profile_image|
      if profile_image.big?
        curr_index += 1
        if(curr_index == index)
          return profile_image.property_image_filename
        end
      end
    end
    # integrate with photo upload support
    curr_index = 0
    self.profile_images.each do |profile_image|
      if profile_image.large?
        curr_index += 1
        if(curr_index == index)
          return profile_image.property_image_filename
        end
      end
    end

    return "/images/property-170.jpg" if self.owner? || self.seller_agent?
    return "" # default, just in case
  end

  
  # Used on message profile dropdown to make it easier to identify the profiles
  def unambiguous_name
    return private_display_name if owner? || seller_agent?
    "#{private_display_name} (#{truncate(zip_code, :length => 15)})"
  end
  
  def match_count_text(count, listing_type)
    if listing_type == 'buyer'
      text = "#{pluralize(count, 'Buyer')}"
    elsif listing_type == 'buyer_agent'
      text = "#{pluralize(count, 'Buyer Agent')}"
    elsif listing_type == 'fsbo'
      text = "#{pluralize(count, 'FSBO Listing')}"
    elsif listing_type == 'listed'
      text = "#{pluralize(count, 'Agent Listing')}"
    else
      if self.buyer? || self.buyer_agent?
        text = "#{pluralize(count, 'Property')}"
      else
        text = "#{pluralize(count, 'Buyer')}"
      end
    end
    text
  end

  def display_match_total_near_count(listing_type)
#    pmc = ProfileMatchesCount.find_by_profile_id(self.id)
#    if pmc.nil? || pmc.count < 0
      total_count = self.count_all(listing_type).to_i + self.near_count_all(listing_type).to_i
#    else
#      total_count = pmc.count
#    end
      
    return total_count
  end

  def display_match_total_near_new_count
      total_count = self.count_new.to_i + self.near_count_new.to_i
    return total_count
  end

  def display_business_phone
    return "<b>Phone:</b> #{self.contact_phone.blank? ? self.user.user_company_info.business_phone : self.contact_phone}<br>" unless self.user.user_company_info.blank?
  end

  def display_after_repair_value
    after_repair_value = self.profile_field_engine_index.after_repair_value
    return (after_repair_value.blank?) ? "" : "#{number_to_currency after_repair_value, :precision => 0}"
  end

  def display_total_repair_needed
    total_repair_needed = self.profile_field_engine_index.total_repair_needed
    return (total_repair_needed.blank?) ? "" : "#{number_to_currency total_repair_needed, :precision => 0}"
  end

  def display_value_determined_by
    if self.profile_field_engine_index.value_determined_by == 'cma'
      return 'CMA'
    else
      return self.profile_field_engine_index.value_determined_by.split(" ").each{|word| word.capitalize!}.join(" ")
    end
  end

  def display_repair_calculated_by
    return self.profile_field_engine_index.repair_calculated_by.split(" ").each{|word| word.capitalize!}.join(" ")
  end

  def display_max_purchase_value
    max_purchase_value = self.profile_field_engine_index.max_purchase_value
    return (max_purchase_value.blank?) ? "" : "#{number_to_currency max_purchase_value, :precision => 0}"
  end

  def display_repairs_value
    return self.profile_field_engine_index.arv_repairs_value
  end

  def default_image_url
    return default_std_thumbnail_url if default_std_thumbnail_url
    if image = ProfileImage.find_by_profile_id_and_thumbnail(self.id,'medium')
      return image.property_image_filename
    end
    self.owner? ? "/images/property-60.jpg" : "/images/buyer-60.jpg"
  end
end

