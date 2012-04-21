class AlertEngine
  
  require "helpers"

  def self.process(logger=Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log"))
    alert_engine = AlertEngine.new(logger)
    alert_engine.generate_alerts()
  end

  def initialize(logger=Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log"))
    @@now = Time.now
    @logger = logger
    @alert_count = 0
  end
  
  def generate_alerts()
    users = User.find(:all, :conditions=>'activation_code is null')
    @logger.info("==================================")
    @logger.info("Starting Alert Engine.............")
    @logger.info("==================================")
    @logger.info("Found #{users.length} users to process")
    alertDefinitions = AlertDefinition.find(:all, :conditions=>["disabled is null or disabled = ?", false])
    @logger.info("Found #{help.pluralize(alertDefinitions.length, "alert definition")} to process")
    users.each do |user|
      alertDefinitions.each do |alert_definition|
        begin
          @logger.debug("")
          @logger.debug("Checking alert [#{alert_definition.title}] for user [#{user.login}]") if @logger.debug?
          add_alert(user, alert_definition) if ! alert_exists?(user, alert_definition) and alert_triggered?(user, alert_definition)
        rescue Exception=>exp
          BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"AlertEngine")
          @logger.info("Couldn't run the aler engine for this #{user.login} for this alert defination #{alert_definition.title}")
        end
      end
    end
    @logger.info("")
    @logger.info("Added #{@alert_count} alerts")
  end
  
  def alert_exists?(user, alert_definition)
     exists = user.alerts.any? { |alert| alert.alert_definition == alert_definition }
     @logger.debug("Already exists") if exists and @logger.debug?
     return exists
  end
  
  def alert_triggered?(user, alert_definition)
     triggered = self.send alert_definition.alert_trigger_type.method_name, user, alert_definition
     @logger.debug("Alert triggered") if triggered and @logger.debug?
    return triggered
  end
  
  def add_alert(user, alert_definition)
    @logger.debug("Adding alert #{alert_definition.title} for user #{user.login}") if @logger.debug?
    alert = Alert.new
    alert.dismissed = false
    alert.event_time = @@now
    alert.alert_definition = alert_definition
    alert.user = user
    alert.save!
    @alert_count += 1
  end


#  The following are used by trigger types

  def never(user, alert_definition)
    false
  end
  
  def always(user, alert_definition)
    true
  end
  
  def all_activated(user, alert_definition)
    true
  end
  
  def on_event(user, alert_definition)
    event_time = user[alert_definition.trigger_parameter_value]
    @logger.debug("Attribute [#{alert_definition.trigger_parameter_value}] is [#{event_time}]") if @logger.debug?
    if no_event?(event_time)
      @logger.debug('Event has not occurred') if @logger.debug?
      return false
    end
    
    if alert_definition.trigger_delay_days
      if too_soon?(event_time, alert_definition.trigger_delay_days)
        @logger.debug("Event is too recent because it did not happen within the last #{alert_definition.trigger_delay_days} days") if @logger.debug?
        return false
      else
        @logger.debug("Event is ok because it happened within the last #{alert_definition.trigger_delay_days} days")
      end
    end
    
    if alert_definition.trigger_cutoff_days
      if too_late?(event_time, alert_definition.trigger_cutoff_days)
        @logger.debug("Event has expired because it did not happen within the last #{alert_definition.trigger_cutoff_days} days") if @logger.debug?
        return false
      else
        @logger.debug("Event happened within the last #{alert_definition.trigger_cutoff_days} days")
      end
    end
    
    return true
  end
  
  def no_event?(event_time)
    return event_time.nil?
  end
  
  def too_soon?(event_time, min_days)
    min_days and @@now - event_time < min_days.days
  end
  
  def too_late?(event_time, max_days)
    max_days and @@now - event_time > max_days.days
  end
  
  def admin_only(user, alert_definition)
    user.admin?
  end

  def domain_matches(user, alert_definition)
    ! user.login.match(Regexp.new(".*@#{alert_definition.trigger_parameter_value}")).nil?
  end
  
  def login_matches(user, alert_definition)
    user.login == alert_definition.trigger_parameter_value
  end

end
