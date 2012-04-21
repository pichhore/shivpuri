class UserCompanyInfo < ActiveRecord::Base
  uses_guid
  validates_uniqueness_of :user_id
  validates_presence_of :business_name
  validates_presence_of :business_address
  validates_presence_of :business_phone
  validates_presence_of :business_email
  validates_presence_of :city
  validates_presence_of :country
  validates_presence_of :state
  validates_presence_of :zipcode
#   validates_numericality_of :zipcode, :if=>:allow_us_validation
#   validates_length_of :zipcode, :is => 5, :if=>:allow_us_validation, :message => "is the wrong length (should be %d characters)"
   validates_format_of :zipcode, :with=>/\A[0-9]{5}\Z/, :if=>:allow_us_validation, :message => "Zip Code should be 5 digit or 5-4 extended format" 
#   validates_numericality_of :zipcode, :if=>:allow_canada_validation
#   validates_length_of :zipcode, :is => 7, :if=>:allow_canada_validation, :message => "is the wrong length (should be %d characters)"
   validates_format_of :zipcode, :with=>/^[A-Za-z0-9]{3} [A-Za-z0-9]{3}$/, :if=>:allow_canada_validation, :message => "Zip code should be a combination of 3 sets of alphanumeric" 
  validates_format_of :business_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_presence_of :user_id

#   validates_format_of :zipcode, :with => /(^([0-9]{5})$)|(^[A-Za-z0-9]{3} [A-Za-z0-9]{3}$)/, :message => lambda{get_valid_format_error_msg}

  validate :validate_zip_code_exists

#  validates_true_for :zipcode,:logic => lambda { validate_zip_code_exists }, :message => lambda{get_validate_zip_msg}

  def get_valid_format_error_msg
    return self.country == "CA" ? "Zip code should be a combination of 3 sets of alphanumeric" : "Zip Code should be 5 digit or 5-4 extended format"
  end

  def validate_zip_code_exists
    coun = self.country.downcase
    if !Zip.find(:first, :conditions => ["zip = ? and country = ? and territory_id is not null", self.zipcode, coun])
        errors.add(:zipcode, get_validate_zip_msg)
    end
  end

  def get_validate_zip_msg
    return "Zip code should be a combination of 3 sets of alphanumeric" if self.country == "CA" and !self.zipcode.match(/^[A-Za-z0-9]{3} [A-Za-z0-9]{3}$/)
    return "Zip Code should be 5 digit or 5-4 extended format" if self.country == "US" and !self.zipcode.match(/^([0-9]{5})$/)
    return "The zip code you entered does not appear to be a valid or working Postal Zip Code"
  end

 
  def allow_canada_validation
    return (zipcode? and country? and country == "CA")
  end

  def allow_us_validation
    return (zipcode? and country? and country == "US")
  end
  
#   def validate
#     unless self.zipcode.to_s.size == 5
#       errors.add("zipcode", "should be 5 digits")
#     end
#   end
  
  def full_address
    return "#{business_address} <br/> #{(city ? (city.to_s+',') : '')} #{(state ? (state.to_s+',') : '')}  #{zipcode}"
  end
  
  def self.find_value(session_var, current_user_id, user_company_info_error)
    if user_company_info_error.nil?
      if !session_var.nil?
        return session_var[0], session_var[1], session_var[2], session_var[3], session_var[4], session_var[5], session_var[6], session_var[7]
      else
        user_company_info = self.find_by_user_id(current_user_id)
        if !user_company_info.blank?
          business_email = user_company_info.business_email.blank? ? current_user.email : user_company_info.business_email
          return user_company_info.business_name, user_company_info.business_address, user_company_info.business_phone, business_email, user_company_info.city, user_company_info.state, user_company_info.zipcode,user_company_info.country
        else
          return "", "", "", current_user.email
        end
      end
    else
      return user_company_info_error.business_name, user_company_info_error.business_address, user_company_info_error.business_phone,user_company_info_error.business_email,user_company_info_error.city,user_company_info_error.state,user_company_info_error.zipcode,user_company_info_error.country
    end
  end
end
