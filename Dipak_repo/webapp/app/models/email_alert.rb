class EmailAlert < ActiveRecord::Base
  uses_guid
  belongs_to :email_alert_definition
  belongs_to :user
end
