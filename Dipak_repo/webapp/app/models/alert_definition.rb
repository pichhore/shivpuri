class AlertDefinition < ActiveRecord::Base
	uses_guid
	acts_as_paranoid
  belongs_to :alert_trigger_type

	validates_presence_of			:title
	validates_presence_of			:message
	validates_presence_of			:alert_trigger_type_id
  #validates_presence_of			:is_welcome_alert
  validates_presence_of			:welcome_alert_expiry, :if => :welcome_alert?
  has_many :alerts, :dependent=>:destroy
  belongs_to :user_class

  def welcome_alert?
    is_welcome_alert == true
  end
end
