require "validatable"
#
# Base class for capturing profile fields from a webform, prior to updating a profile.
#
# See the subclasses for the complex validation logic.
#
class ProfileFieldForm
  include Validatable

  FIELDS = [:property_type,
            :privacy,
            :zip_code,
            :type,
            :property_address,
            :units,
            :units_min,
            :units_max,
            :beds,
            :baths,
            :garage,
            :stories,
            :square_feet,
            :square_feet_min,
            :square_feet_max,
            :neighborhood,
            :condo_community_name,
            :price,
            :price_min,
            :price_max,
            :max_mon_pay,
            :max_dow_pay,
            :min_mon_pay,
            :min_dow_pay,
            :contract_end_date,
            :notification_active,
            :notification_email,
            :deal_terms,
            :video_tour,
            :embed_video,
            :county,
            :acres,
            :acres_min,
            :acres_max,
            :description,
            :feature_tags,
            :trees,
            :waterfront,
            :pool,
            :livingrooms,
            :formal_dining,
            :breakfast_area,
            :school_elementary,
            :school_middle,
            :school_high,
            :total_actual_rent,
            :water,
            :sewer,
            :electricity,
            :natural_gas,
            :house,
            :manufactured_home,
            :barn,
            :fencing,
            :notification_phone,
            :after_repair_value,
            :value_determined_by,
            :total_repair_needed,
            :repair_calculated_by,
            :max_purchase_value,
            :arv_repairs_value,
            :investment_type_id,
            :country,
            :state,
            :city,
            :first_name,
            :last_name ]

  create_attrs FIELDS

  attr_accessor :wholesale_owner, :finance_owner,:force_submit

  def self.fields_array
    return FIELDS
  end

  def self.fields_array_count
    return FIELDS.length
  end

  def self.create_form_for(profile_permalink)
    if profile_permalink == 'buyer' || profile_permalink == 'buyer_agent'
      return BuyerProfileFieldForm.new
    elsif profile_permalink == 'owner' || profile_permalink == 'seller_agent'
      return OwnerProfileFieldForm.new
    end

    # default
    return ProfileFieldForm.new
  end

  def valid_for_property_type?
    return false if self.property_type.blank?
    return valid_for_single_family? if self.property_type == 'single_family'
    return valid_for_multi_family? if self.property_type == 'multi_family'
    return valid_for_condo_townhome? if self.property_type == 'condo_townhome'
    return valid_for_acreage? if self.property_type == 'acreage'
    return valid_for_other?
    return true
  end

  def from_profile_fields(profile_fields)
    profile_fields.each do |profile_field|
      __send__("#{profile_field.key}=", profile_field.value_text || profile_field.value) if respond_to?("#{profile_field.key}=")
    end
  end

  def to_profile_fields
    fields = Array.new
    FIELDS.each do |field|
      unless skip_field?(field)
        value = __send__ "#{field}"
        profile_field = ProfileField.new
        profile_field.key = generate_field_key(field)
        profile_field.value = generate_field_value(field,value)
        profile_field.value_text = rich_text(field, value) if store_in_value_text?(field)
        fields << profile_field
      end
    end
    return fields
  end

  def merge_profile_fields(profile)
    profile_fields = profile.profile_fields
    FIELDS.each do |field|
      key = generate_field_key(field)
      value = __send__ "#{field}"
      profile_field_candidates = profile_fields.select { |pf| pf.key == key }
      profile_field = profile_field_candidates.empty? ? ProfileField.new : profile_field_candidates[0]
      profile_field.value = generate_field_value(field,value)
      profile_field.value_text = rich_text(field, value) if store_in_value_text?(field)
      if profile_field.new_record?
        profile_field.key = key
        profile.profile_fields << profile_field
      end
    end
    return profile
  end

  protected

  def skip_field?(field)
    # Hack removed - UI no longer needs the text boxes within the "optional criteria" section for non-other property types
    return false
  end

  def generate_field_key(field)
    return "#{field}"
  end

  def generate_field_value(field,value)
    # strip commas from currency fields
    return value.split(",").join("") if !value.nil? and (field == :price or field == :price_min or field == :price_max)
    
    # if this is a long text field, set the value to a substring of the whole value
    return rich_text_excerpt(field, value) if !value.nil? and (store_in_value_text?(field))
    # otherwise, just return the value
    return value
  end

  def rich_text_excerpt(field, value)
    return value if value.blank?
    value = rich_text(field, value)
    idx = value.index(/<[(div)(p)(br)(ul)]/i)
    if idx.nil? or idx > 99 or idx == 0
      value = value[0..99]
    else
      value = value[0..(idx-1)]
    end
    value
  end
  
  def rich_text(field, value)
      return value if value.nil?
      # Some browsers send escaped tags, some don't
      # Remove scripts
      # Remove extra line breaks
      # Give lists some class

      value = value.gsub(/&gt;/, ">") \
                   .gsub(/&lt;/, "<") \
                   .gsub(/<script>.*<\/script>/, "") \
                   .gsub(/<script>.*\Z/, "") \
                   .gsub(/(\s*<br\s*\/?>){3,}/,"<br\/><br\/>") \
                   .gsub(/<ul>/,'<ul class="rich_text_list">') \
                   .gsub(/<\/ul><\/li>/,"<\/ul>")
      value << "<br/>" if value.index("text-decoration: underline") && ! value.index(/<br\/>$/)
      return value
  end
  
  def description_field?(field)
    return (field == :description or field == :feature_tags or field == :embed_video or field == :deal_terms)
  end

  def store_in_value_text?(field)
    return (description_field?(field) or field == :zip_code)
  end
end
