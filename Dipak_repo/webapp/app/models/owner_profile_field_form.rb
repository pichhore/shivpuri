#
# Owner Profile form class and validation logic
#
class OwnerProfileFieldForm < ProfileFieldForm

  # :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]

  validates_presence_of :property_type
  validates_presence_of :privacy
  validates_presence_of :zip_code
  validates_presence_of :country
  validates_presence_of :state
  validates_presence_of :beds, :groups => [:single_family, :condo_townhome]
  validates_presence_of :baths, :groups => [:single_family, :condo_townhome]
  validates_presence_of :square_feet, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_presence_of :units, :groups => [:multi_family]
  validates_presence_of :acres, :groups => [:acreage]
  validates_presence_of :property_address, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :if => lambda { self.privacy == "public" and self.property_type != "other"}, :message=>"property address is required for a public profile"
  validates_true_for    :property_address, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :logic => lambda { validate_unique_property_address }, :if => lambda { not self.property_address.nil? and not self.property_address.empty? }, :message=>"This address is already registered"
  validates_presence_of :price, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :if => lambda { self.privacy == "public" }, :message=>"price is required for a public profile"
  validates_presence_of :min_mon_pay, :groups => [:single_family], :if => lambda { self.privacy == "public" and self.finance_owner == true}
  validates_presence_of :min_dow_pay, :groups => [:single_family], :if => lambda { self.privacy == "public" and self.finance_owner == true}
  validates_presence_of :contract_end_date
#   Wholesale strategy fields

  validates_presence_of :after_repair_value, :if => lambda {self.wholesale_owner == true and self.privacy == "public"}
  validates_presence_of :value_determined_by, :if => lambda {self.wholesale_owner == true and self.privacy == "public"}
  validates_presence_of :total_repair_needed, :if => lambda {self.wholesale_owner == true and self.privacy == "public"}
  validates_presence_of :repair_calculated_by, :if => lambda {self.wholesale_owner == true and self.privacy == "public"}

# ........

  validates_format_of :zip_code, :with => /(^([0-9]{5})$)|(^[A-Za-z0-9]{3} [A-Za-z0-9]{3}$)/, :message => lambda{get_valid_format_error_msg}
  
  validates_format_of :square_feet, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_format_of :acres, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:acreage]
  validates_format_of :units, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:multi_family]
  validates_format_of :price, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :if => Proc.new { !price.blank? }, :groups => [ :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]

  validates_format_of :after_repair_value, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :if => Proc.new { !after_repair_value.blank? }, :message=>"is invalid"
  validates_format_of :total_repair_needed, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :if => Proc.new { !total_repair_needed.blank? }, :message=>"is invalid"

  validates_format_of :property_address, :with => /\d+/, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :if => lambda { self.privacy == "public" and self.property_type != "other"}

    validates_format_of :min_mon_pay, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :groups => [:single_family], :if => Proc.new { !min_mon_pay.blank? }
    validates_format_of :min_dow_pay, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :groups => [:single_family], :if => Proc.new { !min_mon_pay.blank? }
  
    validates_format_of :video_tour,
                        :with => /\A(^(www.youtube.com\/watch\?v=)[0-9a-zA-Z\-\_]*$)\Z/,
                        :message => "Please enter a valid youtube URL <br/> (Ex:- www.youtube.com/watch?v=oXW476CyROg)",
                        :if => Proc.new {|profile| !profile.video_tour.blank?}

  #
  # Validate that the property address is unique across all properties (keeps from generating duplicate permalinks for the profile)
  #
  #validates_format_of :description, :with=>/^(?!.*?<a[^<>]*>).*?$/i,:message=>"Please do not add any link in the description"
  validates_true_for :description, :logic => lambda { validate_description }, :message=>"Please do not add any link in the description"
  validates_true_for :zip_code, :logic => lambda { validate_zip_code_exists }, :message => lambda{get_validate_zip_msg}
  validates_true_for :contract_end_date, :logic => lambda {validate_ced}, :message => "Deal expiry date should be some value in the future"

  
  def get_valid_format_error_msg
    return self.country == "CA" ? "Zip code should be a combination of 3 sets of alphanumeric" : "Zip Code should be 5 digit or 5-4 extended format"
  end
  
  def get_validate_zip_msg
    return "Zip code should be a combination of 3 sets of alphanumeric" if self.country == "CA" and !self.zip_code.match(/^[A-Za-z0-9]{3} [A-Za-z0-9]{3}$/)
    return "Zip Code should be 5 digit or 5-4 extended format" if self.country == "US" and !self.zip_code.match(/^([0-9]{5})$/)
    return "The zip code you entered does not appear to be a valid or working Postal Zip Code"
  end

  def validate_unique_property_address
    # TODO: Support checking for Lp vs Loop, St vs Strett, Cr vs Circle, etc. (normalize address to expanded format in DB prior to save?)
    self.property_address = self.property_address.to_s.squeeze("  ").strip
    return true if skip_address_validation?

    deleted = proc{|x| x.profile.nil? ? true : x.profile.permalink.nil?}
    ProfileField.find_all_by_key_and_value("property_address", self.property_address).each do |pf|
      return false unless deleted[pf]
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

  def validate_ced
    unless self.contract_end_date.blank?
    if self.contract_end_date.to_date > Date.today
      return true
    else
      return false
    end
    else
      return true
    end
  end

end
