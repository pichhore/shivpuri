require "validatable"
class InvestorContactUs
  include Validatable
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :message
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  INVESTORCONTACTUSFIELDS = [:name,
                                :phone,
                                :email,
                                :message]
  create_attrs INVESTORCONTACTUSFIELDS

end