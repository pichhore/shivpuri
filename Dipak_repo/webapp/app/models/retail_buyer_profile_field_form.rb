require "validatable"
#
# Base class for capturing profile fields from a webform, prior to updating a profile.
#
# See the subclasses for the complex validation logic.
#
class RetailBuyerProfileFieldForm
  include Validatable

  # :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]
  validates_presence_of :property_type
  validates_presence_of :zip_code
  validates_presence_of :beds, :groups => [:single_family, :condo_townhome]
  validates_presence_of :baths, :groups => [:single_family, :condo_townhome]
  validates_presence_of :square_feet_min, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_presence_of :square_feet_max, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_presence_of :units_min, :groups => [:multi_family]
  validates_presence_of :units_max, :groups => [:multi_family]
  validates_presence_of :acres_min, :groups => [:acreage]
  validates_presence_of :acres_max, :groups => [:acreage]
  validates_presence_of :max_mon_pay, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]
  validates_presence_of :max_dow_pay, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]

  validates_format_of :zip_code, :with => /^\d{5}(,\s*\d{5})*$/
  
  validates_format_of :square_feet_min, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_format_of :square_feet_max, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome]
  validates_format_of :max_mon_pay, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]
  validates_format_of :max_dow_pay, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:single_family, :multi_family, :condo_townhome, :vacant_lot, :acreage, :other]

  validates_true_for :square_feet_max, :if => Proc.new { !square_feet_min.blank? && !square_feet_max.blank? },:logic => lambda { square_feet_max.delete(",").to_i >= square_feet_min.delete(",").to_i }, :groups => [:single_family, :multi_family, :condo_townhome],:message=>"invalid range"
  
  validates_format_of :units_min, :with => /^\d{1}(?:,\d{3}|\d{0,3})$/, :groups => [:multi_family],:message => "must be less than 9999"
  validates_format_of :units_max, :with => /^\d{1}(?:,\d{3}|\d{0,3})$/, :groups => [:multi_family],:message => "must be less than 9999"
  validates_true_for :units_min, :if => Proc.new { !units_min.blank? }, :logic => lambda { units_min.delete(",").to_i > 0}, :groups => [:multi_family],:message=>"must be greater than 0"
  validates_true_for :units_max, :if => Proc.new { !units_min.blank? && !units_max.blank? }, :logic => lambda { units_max.delete(",").to_i >= units_min.delete(",").to_i }, :groups => [:multi_family],:message=>"invalid range"
  
  validates_format_of :acres_min, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:acreage]
  validates_format_of :acres_max, :with => /^\d{1,3}(?:,?\d{3})*$/, :groups => [:acreage]
  validates_true_for :acres_max, :if => Proc.new { !acres_min.blank? && !acres_max.blank? }, :logic => lambda { acres_max.delete(",").to_i >= acres_min.delete(",").to_i }, :groups => [:acreage],:message=>"invalid range"


  RETAILERFIELDS = [:zip_code,
                                :property_type,
                                :beds,
                                :baths,
                                :square_feet_min,
                                :square_feet_max,
                                :units_min,
                                :units_max,
                                :acres_min,
                                :acres_max,
                                :max_mon_pay,
                                :max_dow_pay,
                                :description,
                                :county,
                                :stories,
                                :garage,
                                :livingrooms,
                                :waterfront,
                                :pool,
                                :water,
                                :sewer,
                                :electricity,
                                :natural_gas,
                                :trees]
  create_attrs RETAILERFIELDS


  def valid_for_property_type?
    return false if self.property_type.blank?
    return valid_for_single_family? if self.property_type == 'single_family'
    return valid_for_multi_family? if self.property_type == 'multi_family'
    return valid_for_condo_townhome? if self.property_type == 'condo_townhome'
    return valid_for_acreage? if self.property_type == 'acreage'
    return valid_for_other?
    return true
  end

end