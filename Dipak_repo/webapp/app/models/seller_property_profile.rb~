require "validatable"
#
# Base class for capturing profile fields from a webform, prior to updating a profile.
#
# See the subclasses for the complex validation logic.
#
class SellerPropertyProfile < ActiveRecord::Base

    acts_as_xapian :texts => [ :property_address ],
       :values => [ [ :created_at, 0, "created_at", :date ] ]

  include Validatable
  uses_guid
  attr_accessor :force_submit, :force_zip_not_submit, :force_address_not_submit
  belongs_to :seller_profile
  has_one :profile_contract,  :dependent => :destroy
  has_one :responder_sequence_assign_to_seller_profile
  has_many :seller_financial_infos, :dependent => :destroy
  has_many :seller_engagement_infos, :dependent => :destroy
  has_many :seller_property_owners,  :dependent => :destroy
  has_one :profile_seller_lead_mapping,:dependent => :destroy
  has_one :profile, :through => :profile_seller_lead_mapping 

  validates_presence_of :property_type, :if => lambda {force_submit!= true}
  validates_presence_of :country, :if => lambda {force_submit!= true}
  validates_presence_of :state, :if => lambda {force_submit!= true}
#   validates_presence_of :privacy, :if => lambda {force_submit!= true}
  validates_presence_of :zip_code, :if => lambda {force_submit!= true}
  validates_presence_of :beds, :if => lambda {force_submit!= true}
  validates_presence_of :baths, :if => lambda {force_submit!= true}
  validates_presence_of :square_feet, :if => lambda {force_submit!= true}

   validates_presence_of :property_address, :if => lambda {force_submit!= true}, :message=>"property address is required for a public profile"

#   validates_uniqueness_of :property_address,:case_sensitive =>true, :if => lambda {force_submit!= true}
       validates_true_for    :property_address,  :if => lambda { (force_submit!= true or (!force_address_not_submit.blank? and force_address_not_submit == true)) and not self.property_address.nil? and not self.property_address.empty? },:logic => lambda { validate_unique_property_address }, :message=>"This address is already registered"
# 

#    validates_format_of :zip_code, :with => /^\d{5}(-\d{4})?$/, :if => lambda {allow_us_validation and force_submit!= true}, :message => 'Zip Code should be 5 digit or 5-4 extended format'
    validates_format_of :zip_code, :with => /(^([0-9]{5})$)|(^[A-Za-z0-9]{3} [A-Za-z0-9]{3}$)/, :if => lambda {force_submit!= true or (!force_zip_not_submit.blank? and force_zip_not_submit == true)}, :message => lambda{get_valid_format_error_msg}

# 
#    validates_format_of :square_feet, :with => /^\d{1,3}(?:,?\d{3})*$/, :if => lambda {force_submit!= true}
# 
   validates_format_of :property_address, :with => /\d+/, :if => lambda {force_submit!= true or (!force_address_not_submit.blank? and force_address_not_submit == true)}
# 

     validates_true_for :zip_code, :if => lambda {force_submit!= true or (!force_zip_not_submit.blank? and force_zip_not_submit == true)},:logic => lambda { validate_zip_code_exists }, :message => lambda{get_validate_zip_msg}

  before_save :triggered_before_event
  before_destroy :delete_responder_sequence

  def triggered_before_event
    exist_record  = SellerPropertyProfile.find(:first, :conditions => ["id = ?", self.id])
    if exist_record.blank? 
        Feed.add(self.seller_profile.user_id, get_territory(self.zip_code, self.country), Feed::SELLER_LEAD_ADDED) if !self.zip_code.blank?
    else
        Feed.add(self.seller_profile.user_id, get_territory(self.zip_code, self.country), Feed::SELLER_LEAD_ADDED) if exist_record.zip_code.blank? and !self.zip_code.blank?
    end
  end

  def get_territory(zip,country)
    unless zip.blank?
      @zips = Zip.find_by_zip(zip.split(",").first)
      return @zips.territory_id if !@zips.nil?
    end
  end

  def get_valid_format_error_msg
    return self.country == "CA" ? "Zip code should be a combination of 3 sets of alphanumeric" : "Zip Code should be 5 digit or 5-4 extended format"
  end

  def get_validate_zip_msg
    return "Zip code should be a combination of 3 sets of alphanumeric" if self.country == "CA" and !self.zip_code.match(/^[A-Za-z0-9]{3} [A-Za-z0-9]{3}$/)
    return "Zip Code should be 5 digit or 5-4 extended format" if self.country == "US" and !self.zip_code.match(/^([0-9]{5})$/)
    return "The zip code you entered does not appear to be a valid or working Postal Zip Code"
  end

  def delete_responder_sequence
    responder_sequence_assign_to_seller_profile.destroy if responder_sequence_assign_to_seller_profile
  end 

  def update_property_profile_after_updating_seller_property
  
    fields = ProfileFieldForm.create_form_for("owner")
    property_profile = profile
    seller_property_fields = {:property_type =>property_type,
            :privacy =>privacy,
            :zip_code =>zip_code,
            :property_address =>property_address,
            :beds =>beds.to_s,
            :baths =>baths.to_s,
            :garage =>garage,
            :stories =>stories ,
            :square_feet =>square_feet.to_s,
            :neighborhood=>neighborhood,
            :condo_community_name =>condo_community_name,
#             :price =>asking_home_price,
            :contract_end_date =>(Date.today + 180).to_s(:db),
            :notification_active => 1,
            :notification_email =>notification_email ,
            :deal_terms =>deal_terms ,
            :video_tour => video_tour ,
            :embed_video => embed_video ,
            :county =>county ,
            :description  =>description  ,
            :feature_tags =>feature_tags,
            :trees => feature_tags,
            :waterfront => waterfront,
            :pool => pool,
            :livingrooms =>livingrooms ,
            :formal_dining =>formal_dining ,
            :breakfast_area =>breakfast_area,
            :school_elementary =>school_elementary,
            :school_middle =>school_middle ,
            :school_high =>school_high,
            :total_actual_rent =>total_actual_rent,
            :water =>water,
            :sewer =>sewer,
            :electricity =>electricity,
            :natural_gas =>natural_gas ,
            :house =>house,
            :manufactured_home =>manufactured_home ,
            :barn =>barn,
            :fencing =>fencing,
            :notification_phone =>notification_phone,
            :country => country,
            :state => state
	    }
    fields.from_profile_fields(property_profile.profile_fields)
    fields.from_hash(seller_property_fields)
    fields.merge_profile_fields(property_profile)
    property_profile.profile_fields.each { |field| field.save! }
    property_profile.save!
  end

  def validate_unique_property_address
    # TODO: Support checking for Lp vs Loop, St vs Strett, Cr vs Circle, etc. (normalize address to expanded format in DB prior to save?)
    self.property_address = self.property_address.to_s.squeeze("  ").strip
    return true if skip_address_validation?
    found_field = SellerPropertyProfile.find(:first, :conditions => ["property_address = ?",self.property_address])
    return true if !found_field.blank? and found_field.id == self.id
    if !found_field.nil?
      return false
    end
    return true
  end

  def skip_address_validation?
    return @skip_address_validation || false
  end

  def skip_address_validation!
    @skip_address_validation = true
  end

    def validate_description
    if self.description.match(/<a[^<>]*>|\&lt;a[^<>]*\&gt;/i)
      return false 
    else
      return true
    end
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

  def self.get_seller_property_info(seller_profile)
    property = seller_profile.seller_property_profile[0]
    return property.blank? ? SellerPropertyProfile.new : property
  end


  def validate_zip_code_exists
    coun = self.country.downcase
    unless self.zip_code.blank?
      if Zip.find(:first, :conditions => ["zip = ? and country = ? and territory_id is not null", self.zip_code, coun])
        return true
      else
        return false
      end
    else 
      return true
    end
  end
  
  #Mapping Seller Lead and Property, posted for sell in Market Place
  def self.save_seller_lead_mapping(seller_property_profile_id,profile_id) 
    seller_property_profile = SellerPropertyProfile.find_by_id(seller_property_profile_id)
    seller_profile_id = seller_property_profile.seller_profile_id
    profile_seller_lead_mapping = seller_property_profile.create_profile_seller_lead_mapping(:profile_id=>profile_id,:seller_profile_id=>seller_profile_id)
  end

  def buyer_matches

  end
end
