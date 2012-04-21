class Alert < ActiveRecord::Base
	uses_guid
	belongs_to :alert_definition
	belongs_to :user
end
