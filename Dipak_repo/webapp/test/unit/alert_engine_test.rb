require File.dirname(__FILE__) + '/../test_helper'

class AlertEngineTest < Test::Unit::TestCase
  
  def test_admin_only
    ad = AlertDefinition.create!({:title=>'Admin only',:message=>'Hello, admins',:details=>'You should only be seeing this if you are an admin',
                            :alert_trigger_type=>alert_trigger_types(:admin_only) })
    alert_engine = AlertEngine.new
    assert alert_engine.admin_only(users(:admin), ad)
    assert_equal false, alert_engine.admin_only(users(:quentin), ad)
  end
  
  def test_domain_matches
    ad = AlertDefinition.create!({:title=>'Domain matches',:message=>'Hello, people',:details=>'You should only be seeing this if your domain matches',
                            :alert_trigger_type=>alert_trigger_types(:domain_matches), :trigger_parameter_value=>'dwellgo.com'})
    alert_engine = AlertEngine.new
    user = users(:quentin)
    assert_equal false, alert_engine.domain_matches(user, ad)
    user.login = 'test@dwellgo.com'
    assert alert_engine.domain_matches(user, ad)
  end
  
  def test_login_matches
    ad = AlertDefinition.create!({:title=>'Login matches',:message=>'Hello, people',:details=>'You should only be seeing this if your login matches',
                            :alert_trigger_type=>alert_trigger_types(:login_matches), :trigger_parameter_value=>'foo@dwellgo.com'})
    alert_engine = AlertEngine.new
    user = users(:quentin)
    assert_equal false, alert_engine.login_matches(user, ad)
    user.login = 'foobar@dwellgo.com'
    assert_equal false, alert_engine.login_matches(user, ad)
    user.login = 'foo@dwellgo.com'
    assert alert_engine.login_matches(user, ad)
  end
  
  def test_too_soon
    alert_engine = AlertEngine.new
    assert_equal false, alert_engine.too_soon?(Time.now-2.days, 1)
    assert alert_engine.too_soon?(Time.now-1.days, 2)
  end
  
  def test_too_late
    alert_engine = AlertEngine.new
    assert alert_engine.too_late?(Time.now-2.days, 1)
    assert_equal false, alert_engine.too_late?(Time.now-1.days, 2)
  end
  
  def test_should_do_nothing
    assert_equal 2, Alert.count # 5 from the fixtures
    AlertEngine.process
    assert_equal 2, Alert.count
  end

  def test_should_create_global_alert
    assert_equal 2, Alert.count
    AlertDefinition.create!({:title=>'Global',:message=>'Hello, everybody',:details=>'You should all be seeing this',
                            :alert_trigger_type=>alert_trigger_types(:always) })
    assert_equal 3, AlertDefinition.count
    AlertEngine.process
    assert_equal 2+User.count(:all, :conditions=>'activation_code is null'), Alert.count
  end
  
  def test_should_not_create_alert_before_min_days
    users_activated_over_1000_days_ago = User.count(:conditions=>["activated_at < ?", 1000.days.ago])
    assert_equal 0, users_activated_over_1000_days_ago
    AlertDefinition.create!({:title=>'1000 Days After Activation',:message=>'Hello, activated users',:details=>'You should be seeing this if you were activated recently',
                            :alert_trigger_type=>alert_trigger_types(:on_event), :trigger_parameter_value=>'activated_at', :trigger_delay_days=>1000 })
    assert_equal 3, AlertDefinition.count
    assert_difference 'Alert.count', users_activated_over_1000_days_ago do
      AlertEngine.process
    end
  end
  
  def test_should_create_alert_after_min_days
    users_activated_over_40_days_ago = User.count(:conditions=>["activated_at < ?", 40.days.ago])
    assert_not_same 0, users_activated_over_40_days_ago
    AlertDefinition.create!({:title=>'40 Days After Activation',:message=>'Hello, activated users',:details=>'You should be seeing this if you were activated more than 40 days ago',
                        :alert_trigger_type=>alert_trigger_types(:on_event), :trigger_parameter_value=>'activated_at', :trigger_delay_days=>40 })
    assert_equal 3, AlertDefinition.count
    assert_difference 'Alert.count', users_activated_over_40_days_ago do
      AlertEngine.process
    end
  end
  
  def test_should_create_alert_before_max_days
    users_activated_in_last_40_days = User.count(:conditions=>["activated_at > ?", 40.days.ago])
    assert_not_same 0, users_activated_in_last_40_days
    AlertDefinition.create!({:title=>'40 Days After Activation',:message=>'Hello, activated users',:details=>'You should be seeing this if you were activated recently',
                        :alert_trigger_type=>alert_trigger_types(:on_event), :trigger_parameter_value=>'activated_at', :trigger_cutoff_days=>40 })
    assert_equal 3, AlertDefinition.count
    assert_difference 'Alert.count', users_activated_in_last_40_days do
      AlertEngine.process
    end
  end
  
  def test_should_create_alert_within_window
    users_activated_between_4_and_6_days_ago = User.count(:conditions=>["activated_at > ? and activated_at < ?", 6.days.ago, 4.days.ago])
    assert_not_same 0, users_activated_between_4_and_6_days_ago
    AlertDefinition.create!({:title=>'Between 4 and 6 days ago',:message=>'Hello, activated users',:details=>'You should be seeing this if you were activated between 4 and 6 days ago',
                        :alert_trigger_type=>alert_trigger_types(:on_event), :trigger_parameter_value=>'activated_at', 
                        :trigger_cutoff_days=>6, :trigger_delay_days=>4 })
    assert_equal 3, AlertDefinition.count
    assert_difference 'Alert.count', users_activated_between_4_and_6_days_ago do
      AlertEngine.process
    end
  end
  
  def test_should_not_create_duplicate_alert
    users_activated_between_4_and_6_days_ago = User.count(:conditions=>["activated_at > ? and activated_at < ?", 6.days.ago, 4.days.ago])
    assert_not_same 0, users_activated_between_4_and_6_days_ago
    AlertDefinition.create!({:title=>'Between 4 and 6 days ago',:message=>'Hello, activated users',:details=>'You should be seeing this if you were activated between 4 and 6 days ago',
                        :alert_trigger_type=>alert_trigger_types(:on_event), :trigger_parameter_value=>'activated_at', 
                        :trigger_cutoff_days=>6, :trigger_delay_days=>4 })
    assert_equal 3, AlertDefinition.count
    assert_difference 'Alert.count', users_activated_between_4_and_6_days_ago do
      AlertEngine.process
    end
    count = Alert.count
    AlertEngine.process
    AlertEngine.process
    AlertEngine.process
    assert_equal count, Alert.count
  end
  
  def test_should_not_create_duplicate_alert
    users_activated_between_4_and_6_days_ago = User.count(:conditions=>["activated_at > ? and activated_at < ?", 6.days.ago, 4.days.ago])
    assert_not_same 0, users_activated_between_4_and_6_days_ago
    count = Alert.count
    AlertDefinition.create!({:title=>'Between 4 and 6 days ago',:message=>'Hello, activated users',:details=>'You should be seeing this if you were activated between 4 and 6 days ago',
                        :alert_trigger_type=>alert_trigger_types(:on_event), :trigger_parameter_value=>'activated_at', 
                        :trigger_cutoff_days=>6, :trigger_delay_days=>4, :disabled=>true })
    assert_equal 3, AlertDefinition.count
    assert_equal count, Alert.count
  end
  
  
  def test_should_not_show_alerts_when_definition_deleted
    assert_equal 2, Alert.count
    alert_definition = AlertDefinition.create!({:title=>'Test Delete',:message=>'Hello, everybody',:details=>'You should all be seeing this',
                            :alert_trigger_type=>alert_trigger_types(:always) })
    assert_equal 3, AlertDefinition.count
    AlertEngine.process
    assert_equal 2+User.count(:all, :conditions=>'activation_code is null'), Alert.count
    user = users(:quentin)
    assert_equal 1, user.alerts.length
    assert_equal 'Test Delete', user.alerts.first.alert_definition.title
    alert_definition.destroy!
    user.reload
    assert_equal 0, user.alerts.length
  end
  
  def test_should_not_show_dismissed_alerts
    assert_equal 2, Alert.count
    AlertDefinition.create!({:title=>'Dismissed',:message=>'Hello, everybody',:details=>'You should all be seeing this',
                            :alert_trigger_type=>alert_trigger_types(:always) })
    assert_equal 3, AlertDefinition.count
    AlertEngine.process
    assert_equal 2+User.count(:all, :conditions=>'activation_code is null'), Alert.count
    user = users(:quentin)
    assert_equal 1, user.alerts.length
    
    user.alerts.first.dismissed = true
    user.alerts.first.save!
    
    user.reload
    assert_equal 1, user.alerts.length
    assert_equal 0, user.active_alerts.length
  end

end
