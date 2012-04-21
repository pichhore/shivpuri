#
# Buyer Profile form class and validation logic
#
class BuyerProfileFieldForm < ProfileFieldForm

  # :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]
  attr_accessor :wholesale_buyer, :finance_buyer, :force_submit
  validates_presence_of :property_type
#   validates_presence_of :privacy
  validates_presence_of :zip_code, :if => lambda {is_country_usa and !(!self.force_submit.blank? and self.force_submit == true)}
  validates_presence_of :state, :if => lambda {!is_country_usa and !(!self.force_submit.blank? and self.force_submit == true)}
  validates_presence_of :city, :if => lambda {!is_country_usa and !(!self.force_submit.blank? and self.force_submit == true)}
   validates_presence_of :country, :if => lambda {!(!self.force_submit.blank? and self.force_submit == true)}
  validates_presence_of :beds, :groups => [:single_family, :condo_townhome]
  validates_presence_of :baths, :groups => [:single_family, :condo_townhome]
  validates_presence_of :square_feet_min, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_presence_of :square_feet_max, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_presence_of :units_min, :groups => [:multi_family]
  validates_presence_of :units_max, :groups => [:multi_family]
  validates_presence_of :acres_min, :groups => [:acreage]
  validates_presence_of :acres_max, :groups => [:acreage]
  validates_presence_of :max_mon_pay, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :if => lambda {self.finance_buyer == true}
  validates_presence_of :max_dow_pay, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :if => lambda {self.finance_buyer == true}
  
  # HACK: force validation methods to be generated for these groups that don't have specific fields required
  validates_presence_of :privacy, :groups => [:other, :vacant_lot]

# Owner finance
  validates_presence_of :max_purchase_value, :if => lambda {self.wholesale_buyer == true}
  validates_presence_of :arv_repairs_value, :if => lambda {self.wholesale_buyer == true}
# .......

#   validates_format_of :zip_code, :with => /^\d{5}(,\s*\d{5})*$/

  
  validates_format_of :square_feet_min, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_format_of :square_feet_max, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_format_of :max_mon_pay, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :if => lambda {finance_buyer == true}
  validates_format_of :max_dow_pay, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other], :if => lambda {finance_buyer == true}

  validates_true_for :square_feet_max, :if => Proc.new { !square_feet_min.blank? && !square_feet_max.blank? },:logic => lambda { square_feet_max.delete(",").to_i >= square_feet_min.delete(",").to_i }, :groups => [:single_family, :multi_family, :condo_townhome],:message=>"invalid range"
  
  validates_format_of :units_min, :with => /^\d{1}(?:,\d{3}|\d{0,3})$/, :groups => [:multi_family],:message => "must be less than 9999"
  validates_format_of :units_max, :with => /^\d{1}(?:,\d{3}|\d{0,3})$/, :groups => [:multi_family],:message => "must be less than 9999"
  validates_true_for :units_min, :if => Proc.new { !units_min.blank? }, :logic => lambda { units_min.delete(",").to_i > 0}, :groups => [:multi_family],:message=>"must be greater than 0"
  validates_true_for :units_max, :if => Proc.new { !units_min.blank? && !units_max.blank? }, :logic => lambda { units_max.delete(",").to_i >= units_min.delete(",").to_i }, :groups => [:multi_family],:message=>"invalid range"
  
  validates_format_of :acres_min, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:acreage]
  validates_format_of :acres_max, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:acreage]
  validates_true_for :acres_max, :if => Proc.new { !acres_min.blank? && !acres_max.blank? }, :logic => lambda { acres_max.delete(",").to_i >= acres_min.delete(",").to_i }, :groups => [:acreage],:message=>"invalid range"

  validates_format_of :max_purchase_value, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :if => Proc.new { !max_purchase_value.blank? }, :message=>"is invalid"
  validates_format_of :arv_repairs_value, :with => /^\d{1,3}(?:.?\d{3})*(?:\.\d{0,2})?$/, :if => Proc.new { !arv_repairs_value.blank? }, :message=>"is invalid"

  validates_format_of :price_min, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :if => Proc.new { !price_min.blank? }
  validates_format_of :price_max, :with => /^\d{1,3}(?:,?\d{3})*(?:\.\d{0,2})?$/, :if => Proc.new { !price_max.blank? }
  validates_true_for :price_max, :level => 2, :if => Proc.new { !price_min.blank? && !price_max.blank? }, :logic => lambda { price_max.delete(",").to_f >= price_min.delete(",").to_f },:message=>"invalid range"

 #validates_format_of :description, :with=>/^(?!.*?href).*?$/,:message=>"Please do not add any link in the description." 
validates_true_for :description, :logic => lambda { validate_description }, :message=>"Please do not add any link in the description"
validates_length_of :notification_email, :within => 3..100, :if => lambda {!notification_email.blank?}, :message=>"invalid format"
validates_format_of :notification_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :if => lambda {!notification_email.blank?}, :message=>"invalid format"
#validates_presence_of :first_name
#validates_presence_of :last_name

  def validate_description
    if self.description.match(/<a[^<>]*>|\&lt;a[^<>]*\&gt;/i)
      return false 
    else
      return true
    end
  end

  def is_country_usa
   self.country == "US" ? true : false
  end

end
