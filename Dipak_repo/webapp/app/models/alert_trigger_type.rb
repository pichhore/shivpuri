class AlertTriggerType < ActiveRecord::Base
  uses_guid

	validates_presence_of 			:name
	validates_presence_of 			:method_name
end
