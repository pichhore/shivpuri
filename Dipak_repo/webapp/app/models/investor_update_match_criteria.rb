require "validatable"
class InvestorUpdateMatchCriteria
  include Validatable
  validates_presence_of :zip_code, :message=>"select zip code"
  validates_presence_of :beds
  validates_presence_of :baths
  validates_presence_of :square_feet_min
  validates_presence_of :square_feet_max
  validates_presence_of :max_mon_pay
  validates_presence_of :max_dow_pay

  INVESTORUMCINFO = [:zip_code,
                                :beds,
                                :baths,
                                :square_feet_min,
                                :square_feet_max,
                                :max_mon_pay,
                                :max_dow_pay]
  create_attrs INVESTORUMCINFO

end