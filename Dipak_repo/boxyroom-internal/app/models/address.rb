class Address < ActiveRecord::Base

  # relationships

  belongs_to :addressable, :polymorphic => true
  belongs_to :country, :foreign_key => "country_id"
  
  acts_as_mappable

  # validations
  validates_presence_of :unit_no, :message =>"Enter unit no. in Address"
  validates_presence_of :street_name, :message =>"Enter street name in Address."
  validates_presence_of :city, :message =>"Enter city in Address."
  validates_presence_of :state, :message =>"Enter state in Address."
  validates_presence_of :postal_code, :message =>"Enter postal no in Address."
  validates_presence_of :country_id, :message =>"Enter country id in Address."
  validates_numericality_of :postal_code, :message=>"Postal code must be numeric in Address."

  validates_length_of :unit_no, :maximum => 8, :allow_nil => true, :message=>"Unit no must be less than 9 characters in Address."
  validates_length_of :street_name, :within => 4..64, :allow_nil => true, :message=>"Street name must be greater than 3 characters in Address."
  validates_length_of :city, :within => 2..64, :allow_nil => true, :message=>"City must be greater than 1 character in Address."
  validates_length_of :state, :within => 2..64, :allow_nil => true, :message=>"State must be greater than 1 character in Address."
  validates_length_of :postal_code, :minimum => 4, :allow_nil => true, :message=>"Postal code must be greater than 3 digits in Address."

  before_validation :geocode_address

  # display methods
  
  def location
    "#{street_name}, #{city}, #{country.try(:name)}"
  end

  def to_s
    "#{unit_no} #{street_name}, #{state}, #{city}, #{country.try(:name)} #{postal_code}"
  end
  
  def self.find_address(property_id)
  self.find(:all, :conditions => ["addressable_id=? and addressable_type =? ",property_id, 'Property']).first
  end
  
  private

  def geocode_address
    geo = Geokit::Geocoders::MultiGeocoder.geocode(self.to_s)

    if !geo.success
      errors.add_to_base("Could not Geocode this address.")
    else
      self.lat, self.lng = geo.lat, geo.lng
    end
  end
   
end
