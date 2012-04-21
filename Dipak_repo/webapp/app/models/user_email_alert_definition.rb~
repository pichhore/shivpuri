class UserEmailAlertDefinition < ActiveRecord::Base
  USER_EMAIL_TYPES = [["New", "welcome_reminder"], ["Existing", "existing_welcome_reminder_email"]]
  uses_guid
#   acts_as_paranoid
  belongs_to :alert_trigger_type
  has_many :email_alert_to_users, :dependent => :destroy
  validates_presence_of     :title
  validates_presence_of     :email_type
  validates_presence_of     :email_subject
  validates_presence_of     :message_body
#   validates_presence_of     :alert_trigger_type_id
end
