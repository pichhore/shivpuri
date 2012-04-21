class Profile < ActiveRecord::Base
  include ProfileDisplayHelper
  # require 'securerandom'

  acts_as_xapian :texts => [ :zip_code, :feature_tags, :description, :property_address, :name, :deal_terms],
    :terms => [ [ :type, 'T', "profile_type" ], [:property_type, 'P', "property_type"], [:activated, 'A', "activated"], [:status, 'S', "status" ], [:ownerprofile, 'O', "ownerprofile"], [:profile_city, 'Y', "profile_city"]]

  uses_guid
  uses_permalink :generate_permalink
  acts_as_paranoid
  has_many :profile_sites, :dependent => :destroy
  has_many :buyer_engagement_infos, :dependent => :destroy
  has_one :syndicate_property, :dependent => :destroy
  belongs_to :profile_type
  belongs_to :user
  belongs_to :profile_delete_reason
  belongs_to :investment_type
  has_many :profile_fields
  has_one :profile_field_engine_index
  has_many :profile_favorites, :foreign_key=>"profile_id", :class_name=>"ProfileFavorite", :dependent => :destroy
  has_many :profile_favorites_to_me, :foreign_key => "target_profile_id", :class_name=>"ProfileFavorite", :dependent => :destroy
  has_many :profile_images, :order=>"created_at ASC", :dependent => :destroy
  has_many :profile_images_large, :class_name => "ProfileImage", :conditions => "thumbnail is null", :order => "created_at ASC", :dependent => :destroy
  has_many :profile_viewed_me, :foreign_key=>"profile_id", :class_name=>"ProfileView", :dependent => :destroy
  has_many :profile_viewed_by, :foreign_key=>"viewed_by_profile_id", :class_name=>"ProfileView", :dependent => :destroy
  has_many :profile_message_recipients_from, :foreign_key=>"from_profile_id", :class_name=>"ProfileMessageRecipient", :dependent => :destroy
  has_many :profile_message_recipients_to, :foreign_key=>"to_profile_id", :class_name=>"ProfileMessageRecipient", :dependent => :destroy
  has_many :profile_field_engine_indices, :dependent => :destroy
  has_one :retail_buyer_profile, :dependent => :destroy
  has_one :profile_seller_lead_mapping, :dependent => :destroy
  has_one :seller_property_profile, :through => :profile_seller_lead_mapping 
  has_one :profile_matches_count
  validates_presence_of :random_string
  validates_presence_of :contact_name, :if => :is_property_profile?
  validates_presence_of :contact_phone, :if => :is_property_profile?
  validates_uniqueness_of :random_string

  before_create :before_create
  before_save :before_profile_save
  before_validation :before_validation
  after_destroy :after_destroy
  attr_accessor :url_parameter, :permalink_text, :zip_code, :new_format_url, :profile_need_help_flag, :is_primary_contact_for_property_profile

  @@skip_before_save = false
  cattr_accessor :skip_before_save
  @@skip_permalink_before_save = false
  cattr_accessor :skip_permalink_before_save
  @@skip_matches_update  = false
  cattr_accessor :skip_matches_update

  MAX_PROFILE_IMAGE = 9

  #Will paginate setting for Dashboard Pagination
   cattr_reader :per_page
   @@per_page = 10
  
   named_scope :property_profiles, :conditions => "profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28'"
  
   named_scope :find_profiles_that_need_help, :joins => :user, :conditions => ["is_profile_need_help=?", true], :order => "users.first_name ASC"
   
#  named_scope :find_profiles_that_need_help, :include => [:profile_fields, :profile_images, {:user=>:buyer_user_image}], :conditions => "((profile_fields.key ='description' or (profile_fields.key ='feature_tags' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28')) and (profile_fields.value is null or profile_fields.value = '')) or ( profile_images.id is null and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' ) or ( buyer_user_images.id is null and profiles.profile_type_id = 'ce5c2320-4131-11dc-b431-009096fa4c28' )"
   
   named_scope :find_all_active_buyers, :include => :profile_field_engine_indices, :conditions => "profile_field_engine_indices.is_owner = false AND profile_field_engine_indices.status = 'active' AND profiles.user_id is not null"

   named_scope :find_all_active_wholesale_type_buyers, :include => [:profile_field_engine_indices, :investment_type], :conditions => "profiles.country = 'US' AND profile_field_engine_indices.is_owner = false AND profile_field_engine_indices.status = 'active' AND profiles.user_id is not null and (investment_types.code = 'WS' or investment_types.code = 'WSOF')"

   named_scope :missing_desc_and_feature_tag_profile, :include => :profile_fields, :select =>  "id", :conditions => "(profile_fields.key ='description' and (profile_fields.value is null or profile_fields.value = '')) or (profile_fields.key ='feature_tags' and (profile_fields.value is null or profile_fields.value = '') and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28')"
   
   named_scope :missing_profile_images, :include => :profile_images, :select =>  "id", :conditions=>"profile_images.id is null and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28'"
   
   named_scope :missing_buyer_user_images, :include => {:user=>:buyer_user_image}, :select =>  "id", :conditions => "buyer_user_images.id is null and profiles.profile_type_id = 'ce5c2320-4131-11dc-b431-009096fa4c28'"
   
  # named_scope :find_profile_with_id, lambda { |profile_id| { :conditions => ["id in ?", "#{profile_id}"] } }
   
  def update_seller_property_profile
    profile_field = self.profile_field_engine_index
    seller_property = self.seller_property_profile
    seller_property.update_attributes( :zip_code => profile_field.zip_code, :property_type => profile_field.property_type, :beds => profile_field.beds, :baths => profile_field.baths, :square_feet => profile_field.square_feet, :price => profile_field.price, :units => profile_field.units, :acres => profile_field.acres, :privacy => profile_field.privacy, :property_type_sort_order => profile_field.property_type_sort_order, :has_profile_image => profile_field.has_profile_image, :profile_created_at => profile_field.profile_created_at, :has_features => profile_field.has_features, :has_description => profile_field.has_description, :profile_type_id => profile_field.profile_type_id, :min_mon_pay => profile_field.min_mon_pay, :min_dow_pay => profile_field.min_dow_pay, :contract_end_date => profile_field.contract_end_date, :status => profile_field.status, :notification_email => profile_field.notification_email, :deal_terms => profile_field.deal_terms, :video_tour => profile_field.video_tour, :embed_video => profile_field.embed_video, :notification_phone => profile_field.notification_phone, :property_address => self.field_value("property_address"), :description => self.field_value("description"), :garage => self.field_value("garage"), :stories => self.field_value("stories"), :neighborhood => self.field_value("neighborhood"), :natural_gas => self.field_value("natural_gas"), :electricity => self.field_value("electricity"), :sewer => self.field_value("sewer"), :water => self.field_value("water"), :pool => self.field_value("pool"), :fencing => self.field_value("fencing"), :livingrooms => self.field_value("livingrooms"), :school_elementary => self.field_value("school_elementary"), :school_middle => self.field_value("school_middle"), :school_high => self.field_value("school_high"), :waterfront => self.field_value("waterfront"), :condo_community_name => self.field_value("condo_community_name"), :feature_tags => self.field_value("feature_tags"), :manufactured_home => self.field_value("manufactured_home"), :house => self.field_value("house"), :total_actual_rent => self.field_value("total_actual_rent"), :county => self.field_value("county"), :barn => self.field_value("barn"), :country => self.field_value("country"), :state => self.field_value("state") )
  end


  def is_buyer_wholesale_type?
    return true if !self.investment_type.blank? and self.investment_type.code == "WS"
  end

  def is_buyer_both_type?
    return true if !self.investment_type.blank? and self.investment_type.code == "WSOF"
  end

  def self.find_public_property_profiles
    # Optimization - use a sub-select to create one query - 5-10x faster than the original query
    return self.find(:all, :conditions=>["id in ( select profile_id from profile_field_engine_indices pfei where (pfei.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' or pfei.profile_type_id = 'ce5c2320-4131-11dc-b434-009096fa4c28') and pfei.privacy = 'public')"])
  end

  def self.count_active_buyers(time)
    return self.count_by_sql("SELECT count(DISTINCT profile_id) AS count_profiles_id FROM profile_field_engine_indices pfei, users WHERE pfei.is_owner = false AND DATE(pfei.profile_created_at) <= '#{time.strftime("%Y-%m-%d")}' AND pfei.status = 'active' AND pfei.user_id = users.id AND users.test_comp is null")
  end

  def self.find_profile_by_id_only(id)
    @profile = find_by_sql("SELECT * FROM `profiles`  WHERE (id =  '#{id}' ) limit 1 ")
    @profile[0]
  end
  
  def self.count_active_buyers_for_particular_user(user_id)
    return self.count(:all, :conditions=>["user_id = ? and deleted_at is null and profile_type_id = ?", user_id, "ce5c2320-4131-11dc-b431-009096fa4c28"])
  end
  
  def self.count_active_owners_for_particular_user(user_id)
    return self.count(:all, :conditions=>["user_id = ? and deleted_at is null and profile_type_id = ?", user_id, "ce5c2320-4131-11dc-b432-009096fa4c28"])
  end

  def self.count_sold_property_for_particular_user(user_id)
    return self.count_by_sql("select count(*) from profiles where deleted_at is not null AND user_id = '#{user_id}'")
  end
  
  def self.no_of_deals_completed(user_id)
    return self.count_by_sql("SELECT count(*) FROM `profiles` WHERE (user_id = '#{user_id}' ) AND profile_delete_reason_id is not null")
  end
  
  def self.count_active_owners(time)
    return self.count_by_sql("SELECT count(DISTINCT profile_id) AS count_profiles_id FROM profile_field_engine_indices pfei, users WHERE pfei.is_owner = true AND DATE(pfei.profile_created_at) <= '#{time.strftime("%Y-%m-%d")}' AND pfei.status = 'active' AND pfei.user_id =users.id AND users.test_comp is null")
  end

  def self.count_active_owners_public(time)
    return self.count_by_sql("SELECT count(DISTINCT profile_id) AS count_profiles_id FROM profile_field_engine_indices pfei, users WHERE pfei.privacy = 'public' AND pfei.is_owner = true AND DATE(pfei.profile_created_at) <= '#{time.strftime("%Y-%m-%d")}' AND pfei.status = 'active' AND pfei.user_id =users.id AND users.test_comp is null ")
  end

  def self.count_active_owners_private(time)
    return self.count_by_sql("SELECT count(DISTINCT profile_id) AS count_profiles_id FROM profile_field_engine_indices pfei, users WHERE (pfei.privacy = 'private' OR pfei.privacy is null) AND pfei.is_owner = true AND DATE(pfei.profile_created_at) <= '#{time.strftime("%Y-%m-%d")}' AND pfei.status = 'active' AND pfei.user_id =users.id AND users.test_comp is null ")
  end

  def self.find_by_user(user_id=nil)
    conditions = user_id.nil? ? nil : ["users.id = ?", user_id]
    return self.find(:all, :conditions=>conditions, :order=>"users.first_name, users.last_name, profiles.name", :include=>[:user])
  end

  def self.add_flag_for_profile_which_need_help
    Profile.skip_before_save = true
    Profile.update_all(:is_profile_need_help => false)
    missing_desc_and_feature_tag_profiles = Profile.missing_desc_and_feature_tag_profile
    missing_images_profiles = Profile.missing_profile_images
    missing_buyer_images_profiles = Profile.missing_buyer_user_images
    all_profiles = missing_desc_and_feature_tag_profiles + missing_images_profiles + missing_buyer_images_profiles
    all_profiles.uniq!
    
    all_profiles.each do |profile|
      begin
        profile.profile_need_help_flag = true
        profile.update_attribute(:is_profile_need_help, true)
      rescue Exception => exp
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"AddFlagToProfileWhichNeedHelp")
      end
    end
  end
  
  def self.find_profiles_need_help_admin_reports(page_number)
    all_profiles = Profile.find_profiles_that_need_help    
    profiles = all_profiles.paginate(:page => page_number, :per_page => 20)
    return all_profiles.size, profiles
  end

  def profile_city
    if zip = field_value(:zip_code)
      return zip.split(',').map{|x| Zip.find_by_zip(x).city if Zip.find_by_zip(x)}.join(' ')
    end
  end

  def self.find_profiles_need_help(page_number)
    # 1. Find all profiles that have 0 profile_images
    profile_ids_missing_images_props = Array.new
    profile_ids_missing_images_props = Profile.find(:all, :conditions=> ["profile_images.id is null and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28'"], :include=>[:profile_images, :user])
    
    profile_ids_missing_images_buyers = Array.new
    profile_ids_missing_images_buyers = Profile.find(:all, :conditions=> ["buyer_user_images.id is null and profiles.profile_type_id = 'ce5c2320-4131-11dc-b431-009096fa4c28'"], :include=>[:user => :buyer_user_image])
    
    # 2. Find all profiles that have a missing or null description in profile_fields
    profile_ids_missing_description = Array.new
    profile_ids_missing_description = Profile.find(:all, :conditions=> ["profile_fields.key ='description' and (profile_fields.value is null or profile_fields.value = '')"], :include=>[:profile_fields, :user])

    # 3. Find all property profiles that have a missing or null feature_tags in profile_fields
    profile_ids_missing_tags = Array.new
    profile_ids_missing_tags = Profile.find(:all, :conditions=> ["profile_fields.key ='feature_tags' and (profile_fields.value is null or profile_fields.value = '') and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28'"], :include=>[:profile_fields, :user])
    
    # 4. Combine the results, retrieve profile with assoc user, use the results above for Y/N display on report
    all_profiles = profile_ids_missing_images_props + profile_ids_missing_images_buyers + profile_ids_missing_description + profile_ids_missing_tags
    all_profiles.uniq!
    return Array.new if all_profiles.empty?

    profiles = all_profiles.paginate(:page => page_number, :per_page => 20)
    return profiles, profile_ids_missing_description.map(&:id), profile_ids_missing_images_props.map(&:id), profile_ids_missing_images_buyers.map(&:id), profile_ids_missing_tags.map(&:id), all_profiles.size
  end
  
  #
  # Locates profiles to feature on the homepage
  #
  
  def self.find_featured_profiles(type, number_to_fetch)
    profile_type_id = (type == "buyer") ? "ce5c2320-4131-11dc-b431-009096fa4c28" : "ce5c2320-4131-11dc-b432-009096fa4c28"
    comments_or_tags_key = (type == "buyer") ? "description" : "feature_tags"
    order_by = (type == "buyer") ? "u.last_login_at DESC" : "p.created_at DESC"
    max_number_to_fetch = 50 # fetch 50 and find the first 'number_to_fetch' qualified profiles from the results list
    
    sql = "SELECT distinct p.id as profile_id, u.id as user_id FROM profile_field_engine_indices pfei, profiles p, users u, profile_fields pf, profile_fields pf_property_type WHERE p.id = pfei.profile_id AND p.user_id = u.id AND pf.profile_id = p.id AND pf.key = '#{comments_or_tags_key}' AND pf.value IS NOT NULL AND pfei.has_profile_image = true AND pf_property_type.profile_id = p.id AND pf_property_type.key = 'property_type' AND pf_property_type.value = 'single_family' AND p.profile_type_id = '#{profile_type_id}' AND p.deleted_at IS NULL ORDER BY #{order_by} LIMIT #{max_number_to_fetch}"

    # get the distinct list of profile IDs that match, first
    results = Profile.connection.select_all(sql)
    profile_ids = Array.new

    # extract the profile ids
    users_used_list = Array.new
    results.each do |result|
      user_id = result["user_id"]
      profile_id = result["profile_id"]
      # process each result row until we get the number of profiles desired
      if profile_ids.length < number_to_fetch
        # 544 - limit the buyer profile count to 1 per user, don't limit for owner profiles
        if type == "buyer"
          if !users_used_list.include?(user_id)
            users_used_list << user_id
            profile_ids << profile_id
          end
        else
          profile_ids << profile_id
        end
      end
    end

    return Profile.find(:all, :conditions=>["profiles.id in (?)", profile_ids], :order => "users.last_login_at DESC", :include => [:user])
  end

  def is_property_profile?
    return true if is_primary_contact_for_property_profile and is_primary_contact_for_property_profile == true
    return false
  end

  def before_create
    if !self.user.nil? && !self.private_display_name
      self.private_display_name = generate_private_display_name     
    end
  end
  
  def before_validation    
    flag = true
     while(!flag.nil?)
       rand_str = rand(999999).to_s.rjust(6, '0')
       flag = Profile.find_by_random_string(rand_str)
     end
    self.random_string = rand_str if self.new_record? and self.random_string.nil?
  end
  
  def before_profile_save
    return nil if user.nil? || @@skip_before_save
    generate_name
    generate_permalink
  end

  def property_type
    return field_value( :property_type )
  end

  def property_type_single_family?
    return field_value( :property_type ) == "single_family"
  end

  def property_type_multi_family?
    return field_value( :property_type ) == "multi_family"
  end

  def property_type_condo_townhome?
    return field_value( :property_type ) == "condo_townhome"
  end

  def property_type_vacant_lot?
    return field_value( :property_type ) == "vacant_lot"
  end

  def property_type_acreage?
    return field_value( :property_type ) == "acreage"
  end

  def property_type_other?
    return field_value( :property_type ) == "other"
  end

  def public_profile?
    return (field_value :privacy) == "public"
  end

  def buyer?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b431-009096fa4c28")
  end

  def owner?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b432-009096fa4c28")
  end

  def buyer_agent?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b433-009096fa4c28")
  end

  def seller_agent?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b434-009096fa4c28")
  end

  def service_provider?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b435-009096fa4c28")
  end

  def zip_code
    return field_value( :zip_code )
  end

  def county
    return field_value( :county )
  end

  def ten_days_deleted_at
    return ((self.profile_delete_reason_id == "sold_dwellgo" || self.profile_delete_reason_id == "sold_elsewhere" || self.profile_delete_reason_id == "other_owner") && (self.deleted_at.to_s >  Time.now.to_s(:db))) ? true : false
  end  

  # description, feature_tags, search_name, and property_address are used for search
  def description
    return field_value( :description )
  end
  
  def feature_tags
    return field_value( :feature_tags )
  end

  def deal_terms
    return field_value( :deal_terms )
  end

  def property_address
    return "" unless public_profile?
    field_value( :property_address )
  end
  
  def type
    return (buyer? or buyer_agent?) ? "buyer" : "owner"
  end
  
  def activated
    unless user.nil?
      return user.activated? ? "true" : "false"
   else
      return "false"
   end
  end
  
  def latlng
    # if possible, use cached value (saved in string format for use with google maps)
    latlng = field_value( :latlng )
    geo_ll = field_value( :geo_ll )

    # make sure address isn't new and hasn't changed
    if( self.geocoder_address != geo_ll )
      latlng = ZipCodeMap.lookup_latlng( self.geocoder_address )

      if( get_profile_field( :latlng ) )
        set_profile_field( :latlng, latlng )
      else
        profile_field = ProfileField.new
        profile_field.key = :latlng.to_s
        profile_field.value = latlng

        profile_fields << profile_field
      end

      # save most recent address associated with latlng
      if( get_profile_field( :geo_ll ) )
        set_profile_field( :geo_ll, self.geocoder_address )
      else
        profile_field = ProfileField.new
        profile_field.key = :geo_ll.to_s
        profile_field.value = self.geocoder_address

        profile_fields << profile_field
      end

      # try to save, but object may not pass validation
      begin
        self.skip_matches_update = true
        save!
        self.skip_matches_update = false
      rescue
        self.skip_matches_update = false
      end
    end

    latlng
  end

  def count_matching(listing_type='all',result_filter='all')
    return count_new(listing_type) if result_filter == 'new'
    return count_viewed_me(listing_type) if result_filter == 'viewed_me'
    return count_favorites(listing_type) if result_filter == 'favorites'
    return count_all(listing_type)
  end
  
  def count_all(listing_type='all')
    return MatchingEngine.get_matches(:profile=>self, :mode=>:count, :result_filter=>:all, :listing_type=>listing_type, :use_cache => true)
  end

  def count_new(listing_type='all')
    return MatchingEngine.get_matches(:profile=>self, :mode=>:count, :result_filter=>:new, :listing_type=>listing_type, :use_cache => true)
  end

  def count_viewed_me(listing_type='all')
    return MatchingEngine.get_matches(:profile=>self, :mode=>:count, :result_filter=>:viewed_me, :listing_type=>listing_type)
  end

  def near_count_all(listing_type='all')
    return (self.is_wholesale_profile? or self.is_wholesale_owner_finance_profile?) ? 0 : MatchingEngine.get_matches(:profile=>self, :mode=>:count, :result_filter=>:all, :listing_type=>listing_type, :use_cache => true, :near_match => true)
  end

  def near_count_new(listing_type='all')
    return (self.is_wholesale_profile? or self.is_wholesale_owner_finance_profile?) ? 0 : MatchingEngine.get_matches(:profile=>self, :mode=>:count, :result_filter=>:new, :listing_type=>listing_type, :use_cache => true, :near_match => true)
  end

  def total_near_count_matching(listing_type='all',result_filter='all')
      return (self.is_wholesale_profile? or self.is_wholesale_owner_finance_profile?) ? count_new(listing_type) : count_new(listing_type)+near_count_new(listing_type) if result_filter == 'new'
      return count_viewed_me(listing_type) if result_filter == 'viewed_me'
      return count_favorites(listing_type) if result_filter == 'favorites'
      return (self.is_wholesale_profile? or self.is_wholesale_owner_finance_profile?) ? count_all(listing_type) : count_all(listing_type) + near_count_all(listing_type)
  end


  def count_favorites(listing_type='all')
    return self.profile_favorites.length.to_s
  end

  def count_messages(listing_type='all')
    return ProfileMessageRecipient.count_unread_for(self, listing_type).to_s
  end

  def count_profile_images
    return profile_images.count("id", {:conditions=>["parent_id IS NULL"] })
  end

  def prepare_for_match_display(profile_being_displayed,details_uri="unknown")
    @display_is_favorite = self.is_favorite_of?(profile_being_displayed,self)
    @details_uri = details_uri
  end

  def display_details_uri
    return @details_uri || "NA"
  end

  def display_is_favorite
    return @display_is_favorite
  end

  def is_favorite?(target_profile)
    return is_favorite_of?(self, target_profile)
  end

  def is_favorite_of?(from_profile, to_profile)
    return from_profile.profile_favorites.collect { |favorite_profile| favorite_profile.target_profile_id }.include?(to_profile.id)
  end

  def get_profile_field(key)
    self.profile_fields.each do |field|
      return field if field.key == key.to_s
    end
    return nil
  end

  def set_profile_field(key,value)
    field = get_profile_field(key)
    if !field.nil?
      field.value = value
      return field
    end
    return nil
  end

  def generate_name
    if owner?
      self.name = public_profile? ? (property_type_other? ? "#{zip_code}" : "#{property_address}, #{zip_code}") : "(private), #{zip_code}"
    elsif buyer?
      self.name = "#{user.first_name}"
    else
      self.name = "FIX-ME: Service Provider organization name"
    end
  end

  # generates a private name for the profile based on the type (for the user's convienance only)
  def generate_private_display_name
    if (self.owner? || self.seller_agent?)
      return "#{self.display_property_address_with_zip}"
    elsif (self.buyer? || self.buyer_agent?)
      profile_price_value= self.is_owner_finance_profile? ? self.max_dow_pay : self.max_purchase_value
      return "#{self.display_property_type} #{self.profile_type.name_string} #{self.investment_type.name} #{profile_price_value}"
    else
      return generate_name
    end
  end

  # Helps permalink generation - if this profile is private, use the guid
  def generate_permalink
    return nil if @@skip_permalink_before_save
    return generate_name if public_profile? && owner? && !property_type_other?
    return self.id
  end
  
  # for google map geocoder lookup
  def geocoder_address
    begin
      return self.field_value( :property_address ) + ', ' + self.field_value( :zip_code )
      # return "1800 Nelson Ranch Road, 78613"
    rescue
      return nil
    end
  end

  def reached_profile_images_limit?(current_count)
    return true if current_count >= self.profile_image_limit
    return false
  end

  def profile_image_limit
    return 9 if (self.owner? or self.seller_agent?)
    return 1
  end

  def delete_with_cascade
    begin
      profile_matches = ProfileMatchesDetail.match_exists?(self.id)
      if !profile_matches.empty?
        profile.delete_profile_matches_data(profile_matches)
      end
    rescue Exception=>exp
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,Profile)
    end
  end

  # create an accessor that can be used as a virtual column
  def owned_by
    "#{user.full_name}"
  end

  def after_destroy
    begin
      # prevent duplicates
      log_entry_already_found = ActivityLog.find(:first, :conditions=>["activity_category_id = ? AND profile_id = ? ", 'cat_prof_deleted', self.id])

      # Ticket #524
      reason = "Other"
      
      if (!self.profile_delete_reason_id.nil? && self.profile_delete_reason_id != "other")
        the_profile_delete_reason = ProfileDeleteReason.find(self.profile_delete_reason_id)
        reason = "#{the_profile_delete_reason.name}"
      end
      if(self.profile_delete_reason_id)
      ActivityLog.create!({ :activity_category_id =>'cat_prof_deleted', :user_id=>user_id, :profile_id => self.id,
                            :description => reason, :profile_name => self.profile_name}) if !log_entry_already_found
      end
    rescue => e
      logger.error("Error trying to make an ActivityLog entry: #{e}")
    end
  end
  

  def self.refresh_thumbnails
    # paginate 10 at a time, ask the observer to update the indices
    offset = 0
    per_page = 10
    total = Profile.count("id", :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
    begin
      puts "Processing #{offset+1} - #{(offset+per_page)} of approx #{total}"
      profiles = Profile.find(:all, :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
      profiles.each do |profile|
        # update the profile's index
        self.refresh_thumbnails_for(profile)
      end
      offset += per_page
    end while profiles.length > 0
  end

  def self.refresh_thumbnails_for(profile)
    # grab the first thumbnail for each of the 3 sizes and store into the profile table for faster page loading
    # optimization note: creates a 2-5x perf improvement on page loading
    default_photo = profile.profile_images.find(:first, :conditions=>["thumbnail = 'profile'"], :order=>"created_at")
    default_std   = profile.profile_images.find(:first, :conditions=>["thumbnail = 'medium'"], :order=>"created_at")
    default_micro = profile.profile_images.find(:first, :conditions=>["thumbnail = 'tiny'"], :order=>"created_at")

    default_photo_url = "NULL" if default_photo.nil?
    default_photo_url = "'#{default_photo.public_filename}'" unless default_photo.nil?

    default_std_url = "NULL" if default_std.nil?
    default_std_url = "'#{default_std.public_filename}'" unless default_std.nil?

    default_micro_url = "NULL" if default_micro.nil?
    default_micro_url = "'#{default_micro.public_filename}'" unless default_micro.nil?

    # run an update query as not to disrupt the profile.updated_at value, which is used for reports when a user makes a direct
    # profile change
    begin
      Profile.connection.update("UPDATE profiles SET default_photo_url = #{default_photo_url}, default_std_thumbnail_url = #{default_std_url}, default_micro_thumbnail_url = #{default_micro_url} WHERE id = '#{profile.id}'")
    #rescue => e
    #  @logger.info "Capturing error and continuing: #{e}"
    end
  end
  
  def title_from_type
    return "Buyer" if profile_type.buyer?
    return "Owner" if profile_type.owner?
    return "Seller Agent" if profile_type.seller_agent?
    return "Buyer Agent" if profile_type.buyer_agent?
  end
  
  def self.upload_buyer_profiles(upload)
    name =  upload['datafile'].original_filename
    directory = "public/data"
    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| f.write(upload['datafile'].read) }
  end

  def self.destroy_profile_by_cron
    @profiles = self.find_by_sql("SELECT * FROM `profiles`   WHERE (deleted_at <  '#{(Time.now + 2.day).to_s(:db)}' )")
    @profiles.each do |profile|
      begin
        # Delete cached data and update match count
        profile_matches = ProfileMatchesDetail.match_exists?(profile)
        if !profile_matches.empty?
          profile.delete_profile_matches_data(profile_matches)
        end
        pmc = ProfileMatchesCount.find_by_profile_id(profile.id)
        pmc.destroy unless pmc.nil?
        if ProfileFieldEngineIndex.find_by_profile_id(profile.id)
          if profile.owner?
            profile.permalink = nil
            profile.skip_permalink_before_save = true
            profile.save(false)
          end
          profile.destroy
        end
      rescue Exception=>exp
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,Profile)
      end
    end
  end

  def self.get_bwp_matched_profiles(fields, zip_code_array, page_number)
    cond_array = Array.new
    cond_array[0] = "(beds >= ?) && (baths >= ?) "
    cond_array[1], cond_array[2] = fields[:beds], fields[:baths]
    if !fields[:square_feet_max].blank?
      cond_array[0] << " && (square_feet <= ?) "
      cond_array << fields[:square_feet_max].gsub(',',"")
    end
    if !fields[:square_feet_min].blank?
      cond_array[0] << " && (square_feet >= ?) "
      cond_array << fields[:square_feet_min].gsub(',',"")
    end
    if !fields[:max_mon_pay].blank?
      cond_array[0] << " && (min_mon_pay <= ?) "
      cond_array << fields[:max_mon_pay].gsub(',',"")
    end
    if !fields[:max_dow_pay].blank?
      cond_array[0] << " && (min_dow_pay <= ?) "
      cond_array << fields[:max_dow_pay].gsub(',',"")
    end

    selected_zips = (fields[:zip_code].blank?) ? (zip_code_array) : (zip_code_array & fields[:zip_code].split(","))
    cond_array[0] << " && (zip_code in (?) ) "
    cond_array << selected_zips

    return self.find(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true and users.activation_code is null", :group=>"profile_field_engine_indices.profile_id, profile_field_engine_indices.property_type", :conditions=>cond_array , :order=>"created_at DESC", :limit => page_number*5), self.count(:all, :joins => "INNER JOIN profile_field_engine_indices ON profiles.id = profile_field_engine_indices.profile_id INNER JOIN `users` ON `users`.id = `profiles`.user_id  and status='active' and profiles.profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and profiles.deleted_at IS NULL and is_owner = true and users.activation_code is null", :conditions=>cond_array)
  end

  def self.get_limit_and_offset(total_profiles_fetched,page_number,profiles_per_page)
    toatal_page_a = ( total_profiles_fetched / profiles_per_page ).to_i
    if page_number <= toatal_page_a
       number_to_fetch = 0
       offset = 0
    elsif page_number == (toatal_page_a + 1)
       offset = 0
       number_to_fetch = profiles_per_page - ( total_profiles_fetched % profiles_per_page )
    else
       offset = ( profiles_per_page - ( total_profiles_fetched % profiles_per_page ) ) + ( profiles_per_page * (page_number-(toatal_page_a+2)) )
       number_to_fetch = profiles_per_page
    end
    return offset, number_to_fetch
  end
  
  def owner_email
    "#{user.email}"
  end
  
  def profile_name
    "#{self.buyer? ? (self.private_display_name.include?("Individual") ?  self.display_name : self.private_display_name) : self.display_name}"
  end

  def delete_reason_for_profile
    self.profile_delete_reason.name unless self.profile_delete_reason.blank?
  end

  def medium_thumbnail(parent_id)
    begin
      return self.profile_images.find(:first, :conditions=>["parent_id = ? and thumbnail = 'medium'", parent_id])
    rescue
      return nil
    end
  end
  
  def profile_thumbnail(parent_id)
    begin
      return self.profile_images.find(:first, :conditions=>["parent_id = ? and thumbnail = 'profile'", parent_id])
    rescue
      return nil
    end
  end

  def ownerprofile
    unless profile_field_engine_index.nil?
      if profile_field_engine_index.is_owner?
      end
      return profile_field_engine_index.is_owner?  ? "true" : "false"
    else
      return "true"
    end
  end

  def status
    unless profile_field_engine_index.nil?
      if profile_field_engine_index.active?
      end
      return profile_field_engine_index.active?  ? "true" : "false"
    else
      return "true"
    end
  end

  def delete_profile_matches_data(profile_matches)
    profile_matches.each do |pm|
      pm.destroy unless pm.nil?
    end
  end

  def delete_without_archiving
    Profile.transaction do
      Profile.connection.execute("DELETE FROM profile_fields WHERE profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_images WHERE profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM featured_profiles WHERE profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_matches_counts WHERE profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_matches_details WHERE source_profile_id = '#{self.id}' OR target_profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_message_recipients WHERE from_profile_id = '#{self.id}' OR to_profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_views WHERE profile_id = '#{self.id}' OR viewed_by_profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_favorites WHERE profile_id = '#{self.id}' OR target_profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_field_engine_indices WHERE profile_id = '#{self.id}'")
      self.profile_matches_count.destroy if self.profile_matches_count
      self.retail_buyer_profile.destroy if self.retail_buyer_profile
      self.destroy!
    end
  end

  def delete_profile_related_info
    Profile.transaction do
      Profile.connection.execute("DELETE FROM profile_matches_details WHERE source_profile_id = '#{self.id}' OR target_profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_message_recipients WHERE from_profile_id = '#{self.id}' OR to_profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_views WHERE profile_id = '#{self.id}' OR viewed_by_profile_id = '#{self.id}'")
      Profile.connection.execute("DELETE FROM profile_favorites WHERE profile_id = '#{self.id}' OR target_profile_id = '#{self.id}'")      
      self.profile_matches_count.destroy if self.profile_matches_count
    end
  end

  def is_wholesale_profile?
    self.investment_type.id == InvestmentType.find_by_code("WS").id ? true : false
  end

  def is_owner_finance_profile?
    self.investment_type.id == InvestmentType.find_by_code("OF").id ? true : false
  end

  def is_wholesale_owner_finance_profile?
    self.investment_type.id == InvestmentType.find_by_code("WSOF").id ? true : false
  end

  def buyer_website_url_for_buyer_leads
    sites = self.user.buyer_websites
    puts sites.inspect
    if sites.blank?
      return ""
    end
    vanity_site = sites.select{|x| x.having?}[0]
    return vanity_site.new_format_url if vanity_site
    return sites[0].new_format_url
  end

  def property_synd_url
    sites = self.user.buyer_websites
    puts sites.inspect
    if sites.blank?
      return "http://www.buyhome4.us/#{self.random_string}"
    end
    vanity_site = sites.select{|x| x.having?}[0]
    return vanity_site.new_format_url_for_syndication+"/#{self.random_string}" if vanity_site
    return sites[0].new_format_url_for_syndication+"/#{self.random_string}"
  end

  def soft_delete(profile_form)
    attr_update_hash = Hash.new
    attr_update_hash["permalink"] = nil
    attr_update_hash["deal_deleted_at"] = Time.now 
    attr_update_hash["delete_reason"] = profile_form.delete_reason unless profile_form.delete_reason.blank?    
    attr_update_hash["profile_delete_reason_id"] = profile_form.profile_delete_reason_id
    if self.owner?
      attr_update_hash["deleted_at"] = (Time.now + 10.year).to_s(:db) 
      attr_update_hash["profile_delete_date"] = (Time.now).to_s(:db)
    end
    
    self.profile_fields.each do |pro|
      if pro.key == "zip_code"
        zips_string = pro.value.blank? ? self.profile_field_engine_index.zip_code : pro.value 
        zips = Zip.find_by_zip(zips_string.split(",").first)
        territory_id = zips.territory_id unless zips.nil?
        self.buyer? ?
          Feed.add(self.user_id, territory_id, Feed::PROPERTY_BOUGHT) :
          Feed.add(self.user_id, territory_id, Feed::PROPERTY_SOLD)
      end
    end

    self.attributes = attr_update_hash
    self.skip_permalink_before_save = true
    self.save(false)

    self.skip_permalink_before_save = false
    self.reload  # force the model to reload the changed data
    profile_mapping = self.profile_seller_lead_mapping

    unless profile_mapping.blank?
      seller_info = profile_mapping.seller_profile
      if profile_mapping.destroy 
        new_seller_property = seller_info.seller_property_profile.build
        new_seller_property.force_submit = true
        new_seller_property.save
      end
    end
        
    if !(self.profile_type.name == "owner" && ( profile_form.profile_delete_reason_id == 'sold_dwellgo' || profile_form.profile_delete_reason_id == 'sold_elsewhere' ))
      self.destroy
    else
      self.delete_profile_related_info
      log_entry_already_found = ActivityLog.find(:first, :conditions=>["activity_category_id = ? AND profile_id = ? ", 'cat_prof_deleted', self.id])
      if !self.profile_delete_reason_id.blank? && self.profile_delete_reason_id != "other"
        reason = ProfileDeleteReason.find(self.profile_delete_reason_id).name.to_s
      end
      ActivityLog.create!({ :activity_category_id => 'cat_prof_deleted', :user_id => current_user.id, :profile_id => self.id, :description => reason}) if !log_entry_already_found
    end

    #Award a Badge to user when destroy a profile
    BadgeUser.reward_badge_for_the_user(current_user)
  end
end


  
