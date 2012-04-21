class SyndicateProperty < ActiveRecord::Base
  include ProfileDisplayHelper
  belongs_to :profile

  def self.save_auto_syndicate_property(profile_id, profile_fields, user)
    property = self.find_or_create_by_profile_id(profile_id)
    property.assign_profile_fields(profile_fields, user)
    Rails.logger.info "Syndicate property#save_auto_syndicate_property#------------#{property.inspect}"
    property.save!    
  end

  def self.save_manual_syndicate_property(profile_id, user, active=true)
    profile_fields = ProfileField.find_all_by_profile_id(profile_id)    
    property = self.find_or_create_by_profile_id(profile_id)
    profile_image = ProfileImage.find_by_profile_id(profile_id, :conditions => {:thumbnail => "big"})
    property.image_link = REIMATCHER_URL + "images/property-170.jpg"
    property.image_link = REIMATCHER_URL + "profile_images/#{profile_image.parent_id}/#{profile_image.filename}" if !profile_image.nil?
    property.is_active = active
    property.assign_profile_fields(profile_fields, user)
#    property.post_property_to_twitter(user) if user.twitter
#    property.post_property_to_facebook(user) if !user.fb_access_token.blank?
    Rails.logger.info "Syndicate property#save_property#------------#{property.inspect}"
    property.save!
  end

  def assign_profile_fields(profile_fields, user)
    undesired_fields = %w{privacy units_min units_max square_feet_min square_feet_max price_min price_max max_mon_pay max_dow_pay notification_active notification_email acres_min acres_max trees formal_dining breakfast_area notification_phone latlng geo_ll type after_repair_value value_determined_by total_repair_needed repair_calculated_by max_purchase_value arv_repairs_value finance_owner wholesale_owner finance_buyer wholesale_buyer investment_type_id first_name last_name}

    profile_fields.each{ |field| 
      case field.key
      when "square_feet" 
        fvalue = field.value.gsub(/[^0-9]/, "") if !field.value.nil?
      when "baths"
        fvalue = property_bathrooms_display_hash[field.value]
      when "description"
        fvalue = field.value_text.gsub(/<(.|\n)*?>/, '') if !field.value.nil?
      else
        fvalue = field.value
      end
      self.send "#{field.key}=", fvalue if !undesired_fields.include?(field.key) 
    }
    assign_title_and_description
    profile = self.profile
    user = User.find(user) if user.class == String ## Showing string class on staging
    user_company_info = user.user_company_info
    self.business_email = user.email
    self.business_phone = user.mobile_phone
    self.business_phone = user_company_info.business_phone if !user_company_info.nil?
    self.business_phone = profile.contact_phone if !profile.contact_phone.blank?
    self.business_email = user_company_info.business_email if !user_company_info.nil?
    self.property_link = profile.property_synd_url
    self.published_date = profile_fields.first.created_at
    self.agent_email = user_company_info.business_email if !user_company_info.nil? && check_for_investor_type(user.investor_types)
  end

  def assign_title_and_description
    @zip = Zip.find_by_zip(self.zip_code)
    if !@zip.nil?
    inv_type_code = self.profile.investment_type.code unless self.profile.investment_type.nil?
    case inv_type_code
    when "OF"
      prop_title = "A Nice Owner Finance Home"
      prop_desc_text = "Owner Finance Home"
    when "WS"
      prop_title = "Just Posted Wholesale Property"
      prop_desc_text = "Wholesale Property"
    when "WSOF"
      prop_title = "A Nice Wholesale Home for Sale w/ Financing"
      prop_desc_text = "Wholesale Home for Sale w/ Financing"
      
    else
      prop_title = "A Nice Owner Finance Home"
      prop_desc_text = "Owner Finance Home"
    end
      self.title = "#{prop_title} in #{@zip.city}"
      self.description = "#{prop_desc_text} in #{@zip.city}.  Home has #{self.square_feet} Sq Ft, with #{self.beds} beds, #{self.baths} baths..  Check out the pictures and contact us if interested..." if self.description.blank?
      self.latitude = @zip.lat
      self.longitude = @zip.lng
    else
      self.title = "A Nice Owner Finance Home in #{self.property_address}"
      self.description = "Owner Finance Home in #{self.property_address}.  Home has #{self.square_feet} Sq Ft, with #{self.beds} beds, #{self.baths} baths..  Check out the pictures and contact us if interested..." if self.description.blank?
    end
  end

  def post_property_to_twitter(user)
    begin
    consumer = OAuth::Consumer.new(OAUTH_CREDENTIALS[:twitter][:key], OAUTH_CREDENTIALS[:twitter][:secret], :site => "http://api.twitter.com", :scheme => :header)
    access_token = OAuth::AccessToken.from_hash(consumer, :oauth_token => user.twitter.token, :oauth_token_secret => user.twitter.secret)
    bitly = Bitly.new(BITLY_UID, BITLY_API_KEY)
    page_url = bitly.shorten(self.property_link.gsub('localhost', '127.0.0.1'))
    short_url = page_url.shorten
    inv_type_code = self.profile.investment_type.code unless self.profile.investment_type.nil?
    case inv_type_code
    when "OF"
      tweet_title = "Owner Finance Home For Sale"
    when "WS"
      tweet_title = "Just Posted Wholesale Property"
    when "WSOF"
      tweet_title = "Wholesale Home for Sale w/ Financing"
    else
      tweet_title = "Owner Finance Home For Sale"
    end
      property = "#{tweet_title} - " + self.property_address + ", " + "$" + self.price + ".. " + self.description + " " 
    tweet = property  + short_url
    tweet = property[0..116] + ".. " + short_url if tweet.length > 140
    response = access_token.post("http://api.twitter.com/1/statuses/update.json", {:status => tweet})
    rescue Exception => exp
    #To Do, Handle Exceptions
      Rails.logger.info "Error encountered while syndicating property to twitter------------#{exp}"
      return true
    end
  end
  
  def post_property_to_facebook(user)
    begin
    client = FacebookOAuth::Client.new(
                                       :application_id => FACEBOOK[:key],
                                       :application_secret => FACEBOOK[:secret],
                                       :token => user.fb_access_token
                                       )

    inv_type_code = self.profile.investment_type.code unless self.profile.investment_type.nil?
    case inv_type_code
    when "OF"
      fb_message = "A Nice Owner Finance Home"
    when "WS"
      fb_message = "New Discount Property Posted for Sale"
    when "WSOF"
      fb_message = "Discount Property for Sale w/ Financing"
    else
      fb_message = "A Nice Owner Finance Home"
    end
      client.me.feed(:create, :message => fb_message, :link => self.property_link, :name => self.property_address + ' | Powered by REIM', :caption => 'http://www.reimatcher.com', :description => self.description, :picture => self.image_link)
    rescue Exception => exp
      Rails.logger.info "Error encountered while syndicating property to facebook------------#{exp}"
      return true
    #To Do, Handle Exceptions
    end
  end

  def check_for_investor_type(investor_types)
    investor_types.each do |x|
      if x.investor_type == 'LA'
        return true 
        break 
      end
    end
    return false
  end
end
