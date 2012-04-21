class EmailAlertEngine
  
  require "helpers"
  require 'tlsmail'

  def self.process(logger=Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log"))
    email_alert_engine = EmailAlertEngine.new(logger)
    email_alert_engine.generate_email_alerts()
  end

  def initialize(logger=Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log"))
    @@now = Time.now
    @logger = logger
    @email_alert_count = 0
  end
  
  def generate_email_alerts()
    users = User.find(:all, :conditions=>'activation_code is null')
    profiles = ProfileFieldEngineIndex.find(:all,:conditions => "is_owner is true")
    @logger.info("==================================")
    @logger.info("Starting Email Alert Engine.............")
    @logger.info("==================================")
    #    @logger.info("Found #{users.length} users to process")
    @logger.info("Found #{profiles.length} profiles to process")
    #    email_alertDefinitions = EmailAlertDefinition.find(:all, :conditions=>["disabled is null or disabled = ?", false])
    email_alertDefinitions = EmailAlertDefinition.find(:all,:conditions => {:email_type => "property_profile"})
    @logger.info("Found #{help.pluralize(email_alertDefinitions.length, "alert definition")} to process")
    profiles.each do |profile|        
      email_alertDefinitions.each do |email_alert_definition| 
        begin
          #Ticket 830 Change Rails finder method to return nil instead of raising the error
          profile_object = Profile.find_by_id(profile.profile_id)
          if !profile_object.blank?
            user = User.find_by_id(profile_object.user_id)
            @logger.debug("Could not find user with ID:- #{profile_object.user_id}") and next if user.blank?
            if(email_alert_definition.alert_trigger_type.name=="Admin-only" && user.admin_flag==true)
              @logger.debug("")
              @logger.debug("Checking Admin-only alert <b>[#{email_alert_definition.title}]</b> for user <b>[#{user.login}]</b>") if @logger.debug?
              if(email_alert_definition.disabled == false or email_alert_definition.disabled.nil?)
                add_email_alert(user, email_alert_definition, profile) if !email_alert_exists?(user, email_alert_definition,profile)
              else
                @logger.debug("Alert found but <b style='color:red'>disabled</b>, hence alert not added to email_alerts table")
              end
            else
              if(!profile.contract_end_date.blank?)
                if((profile.contract_end_date.to_date) - (email_alert_definition.trigger_delay_days.to_i) == Date.today)          
                  @logger.debug("")
                  @logger.debug("Checking alert <b>[#{email_alert_definition.title}]</b> for user <b>[#{user.login}]</b>") if @logger.debug?
                  if(email_alert_definition.disabled == false or email_alert_definition.disabled.nil?)
                    if !email_alert_exists?(user, email_alert_definition,profile)
                      add_email_alert(user, email_alert_definition,profile) 
                      if(email_alert_definition.trigger_delay_days == 0)
                        profile.update_attributes!(:status => 'inactive')
                        # Delete cached data and update match count
                        profile_obj = Profile.find_by_id(profile.profile_id)
                        unless profile_obj.nil?
                          profile_matches = ProfileMatchesDetail.match_exists?(profile_obj)
                          if !profile_matches.empty?
                            profile_obj.delete_profile_matches_data(profile_matches)
                          end
                        end
                        @logger.debug("Property expired for user [#{user.login}]") if @logger.debug?
                        log_entry_already_found = ActivityLog.find(:first, :conditions=>["activity_category_id = ? AND profile_id = ? ", 'cat_prof_deleted', profile.profile_id])
                        ActivityLog.create!({ :activity_category_id=>'cat_prof_deleted', :user_id=>user.id, :profile_id=>profile.profile_id, :description=>"Property Expired"}) if !log_entry_already_found
                      end
                      @logger.debug("Property expired for user [#{user.login}]") if @logger.debug?
                    end
                  else            
                    @logger.debug("Alert found but <b style='color:red'>disabled</b>, hence alert not added to email_alerts table")
                  end
                end
              end
            end
          end
        rescue Exception=>exp
          BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"EmailAlertEngine")
          @logger.info("Could not start Email Alert Engine for this Profile Id:: #{profile.profile_id}")
        end
      end            
    end
    @logger.info("")
    @logger.info("Added #{@email_alert_count} email alerts")
    # Ticket #109-create buyer expiration email alerts
    begin
      generate_buyer_email_alerts(users, @logger)
    rescue
      @logger.info("Could not generate any buyer email alerts")
    end
  end  
  
  def email_alert_exists?(user, email_alert_definition,profile)     
    exists = user.email_alerts.any? { |email_alert| email_alert.email_alert_definition == email_alert_definition  and email_alert.profile == profile.profile_id}
    @logger.debug("Already exists") if exists and @logger.debug?
    return exists
  end
  
  def email_alert_triggered?(user, email_alert_definition)
    triggered = self.send email_alert_definition.alert_trigger_type.method_name, user, email_alert_definition
    @logger.debug("Alert triggered") if triggered and @logger.debug?
    return triggered
  end
  
  def add_email_alert(user, email_alert_definition, profile)
    @logger.debug("<b style='color:green'>Adding</b> email alert [#{email_alert_definition.title}] for user <b>[#{user.login}]</b>") if @logger.debug?
    email_alert = EmailAlert.new
    #~ if email_alert_definition.trigger_delay_days == 0
      #~ email_alert.event_time = Date.today + 5;
    #~ else
      email_alert.event_time = @@now
    #~ end
    email_alert.email_alert_definition = email_alert_definition
    email_alert.user = user
    email_alert.profile = profile.profile_id
    email_alert.save!
    @email_alert_count += 1
  end


#  The following are used by trigger types

 
  def all_activated(user, email_alert_definition)
    true
  end
  
  def on_event(user, email_alert_definition)
    event_time = user[email_alert_definition.trigger_parameter_value]
    @logger.debug("Attribute [#{email_alert_definition.trigger_parameter_value}] is [#{event_time}]") if @logger.debug?
    if no_event?(event_time)
      @logger.debug('Event has not occurred') if @logger.debug?
      return false
    end
    
    if email_alert_definition.trigger_delay_days
      if too_soon?(event_time, email_alert_definition.trigger_delay_days)
        @logger.debug("Event is too recent because it did not happen within the last #{alert_definition.trigger_delay_days} days") if @logger.debug?
        return false
      else
        @logger.debug("Event is ok because it happened within the last #{alert_definition.trigger_delay_days} days")
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
  
  def admin_only(user, email_alert_definition)
    user.admin?
  end
  
  def email_settings
    
  end

  def generate_buyer_email_alerts(users,logger)
    profiles = ProfileFieldEngineIndex.find(:all,:conditions => ["is_owner=? and status=?",false,"active"], :group => "profile_id")
    logger.info("==================================")
    logger.info("Starting Email Alert Engine.............")
    logger.info("==================================")
    logger.info("Found #{profiles.length} profiles to process")
    #    email_alertDefinitions = EmailAlertDefinition.find(:all, :conditions=>["disabled is null or disabled = ?", false])
    email_alertDefinitions = EmailAlertDefinition.find(:all,:conditions => {:email_type => "buyer_profile"})
    logger.info("Found #{help.pluralize(email_alertDefinitions.length, "alert definition")} to process")
    profiles.each do |profile|
      user = User.find_by_id(profile.user_id)
      unless user.blank?
        if(!profile.contract_end_date.blank?)
          email_alertDefinitions.each do |email_alert_definition| 
            begin
              if((profile.contract_end_date.to_date) - (email_alert_definition.trigger_delay_days.to_i) == Date.today)          
                logger.debug("")
                logger.debug("Checking alert <b>[#{email_alert_definition.title}]</b> for user <b>[#{user.login}]</b>") if logger.debug?
                if(email_alert_definition.disabled == false or email_alert_definition.disabled.nil?)
                  if !email_alert_exists?(user, email_alert_definition,profile)
                    add_email_alert(user, email_alert_definition,profile) 
                    if(email_alert_definition.trigger_delay_days == 0)
                      pfei_array = ProfileFieldEngineIndex.find(:all, :conditions => {:profile_id => profile.profile_id})
                      unless pfei_array.empty?
                        pfei_array.each do |pfei|
                          pfei.update_attributes!(:status => 'inactive')
                        end
                      end
                      # Delete cached data and update match count
                      profile_obj = Profile.find_by_id(profile.profile_id)
                      unless profile_obj.nil?
                        profile_matches = ProfileMatchesDetail.match_exists?(profile_obj)
                        if !profile_matches.empty?
                          profile_obj.delete_profile_matches_data(profile_matches)
                        end
                      end
                      logger.debug("Buyer expired for user [#{user.login}]") if logger.debug?
                      log_entry_already_found = ActivityLog.find(:first, :conditions=>["activity_category_id = ? AND profile_id = ? ", 'cat_prof_deleted', profile.profile_id])
                      ActivityLog.create!({ :activity_category_id=>'cat_prof_deleted', :user_id=>user.id, :profile_id=>profile.profile_id, :description=>"Buyer Expired"}) if !log_entry_already_found
                    end
                  end
                else            
                  logger.debug("Alert found but <b style='color:red'>disabled</b>, hence alert not added to email_alerts table")
                end
              end
            rescue Exception=>exp
              BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"EmailAlertEngine")
              logger.info("Could not start Email Alert Engine for this Profile Id:: #{profile.profile_id}")
            end
          end
        else
          # Update contract end date for existing buyer profiles as created_at +180 days,
          # so that the buyer profile which are created more than six months ago will
          # be expired in the next block
          profile_obj = Profile.find_by_id(profile.profile_id)
          unless profile_obj.nil?
            pfei_array = ProfileFieldEngineIndex.find(:all, :conditions => {:profile_id => profile_obj.id})
            profile_field_cd = ProfileField.find(:first, :conditions => ["profile_id=? AND profile_fields.key LIKE ?",profile_obj.id, 'contract_end_date'])
            unless profile_field_cd.blank?
              profile_field_cd.update_attribute('value',(profile_obj.created_at.to_date+180).to_s(:db))
            else
              pf_cd = ProfileField.create(:key => "contract_end_date", :value => (profile_obj.created_at.to_date+180).to_s(:db), :profile_id => profile_obj.id)
              pf_cd.save!
            end
            unless pfei_array.empty?
              pfei_array.each do |pfei|
                pfei.update_attributes!(:contract_end_date => (profile_obj.created_at.to_date+180).to_s(:db))
              end
            end
            logger.debug("Buyer contract_end_date updated for [#{user.login}]") if logger.debug?
          end
        end
        # For expiring buyer profiles if email_alert_definition not created
        if (!profile.contract_end_date.blank?)
          if((profile.contract_end_date.to_date) < Date.today)          
            pfei_array = ProfileFieldEngineIndex.find(:all, :conditions => {:profile_id => profile.profile_id})
            unless pfei_array.empty?
              pfei_array.each do |pfei|
                pfei.update_attributes!(:status => 'inactive')
              end
              # Delete cached data and update match count
              profile_obj = Profile.find_by_id(profile.profile_id)
              unless profile_obj.nil?
                profile_matches = ProfileMatchesDetail.match_exists?(profile_obj)
                if !profile_matches.empty?
                  profile_obj.delete_profile_matches_data(profile_matches)
                end
              end
              log_entry_already_found = ActivityLog.find(:first, :conditions=>["activity_category_id = ? AND profile_id = ? ", 'cat_prof_deleted', profile.profile_id])
              ActivityLog.create!({ :activity_category_id=>'cat_prof_deleted', :user_id=>user.id, :profile_id=>profile.profile_id, :description=>"Buyer Expired"}) if !log_entry_already_found
            end
            logger.debug("Buyer expired for user [#{user.login}] automatically") if logger.debug?
          end
        end     
      end
    end
    logger.info("")
    logger.info("Added #{@email_alert_count} email alerts")
  end
  
end
