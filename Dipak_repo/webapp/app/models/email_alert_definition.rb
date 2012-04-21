class EmailAlertDefinition < ActiveRecord::Base
  EMAIL_TYPES = [["Property Expiration", "property_profile"],["Buyer Expiration", "buyer_profile"]]
  uses_guid
  acts_as_paranoid
  belongs_to :alert_trigger_type

  validates_presence_of     :title
  validates_presence_of     :email_type
  validates_presence_of     :email_subject
  validates_presence_of     :message_body
  validates_presence_of     :alert_trigger_type_id
end
