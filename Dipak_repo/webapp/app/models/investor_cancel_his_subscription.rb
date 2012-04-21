require "validatable"
#
# Base class for capturing profile fields from a webform, prior to updating a profile.
#
# See the subclasses for the complex validation logic.
#
class InvestorCancelHisSubscription
  include Validatable

  validates_presence_of :reason, :message => "Please specify why Are You Cancelling?"
  validates_presence_of :name, :message => "Please enter your name"

  INVESTORCANCELHISSUBS = [:reason,
                                  :name,
                                  :understand]
  create_attrs INVESTORCANCELHISSUBS

end
