#ticket 594
class ExpiredAlertsDismissedWorker
@queue = :alerts_queue

  def self.perform
Rails.logger.info "running"
   
  Alert.find_in_batches(:batch_size => 100, :joins => :alert_definition, :conditions => "alerts.alert_definition_id = alert_definitions.id AND DATE_ADD(alerts.created_at, INTERVAL alert_definitions.trigger_cutoff_days DAY) < CURRENT_TIMESTAMP AND alerts.dismissed = false",  :readonly => false) { |batch|
    batch.each { |i| i.dismissed = true
    #puts i.inspect
    i.save!
    }
 }




   
  end
end

