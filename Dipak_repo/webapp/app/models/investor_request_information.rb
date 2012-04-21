require "validatable"
class InvestorRequestInformation
  include Validatable
  validates_presence_of :reason
  validates_presence_of :phone
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "e-mail is invalid"

  INVESTORREQUESTINFOFIELDS = [:reason,
                                :name,
                                :phone,
                                :email,
                                :message]
  create_attrs INVESTORREQUESTINFOFIELDS

end
