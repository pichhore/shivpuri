require File.dirname(__FILE__) + '/../test_helper'

class AlertTriggerTypeTest < ActiveSupport::TestCase
  
  def test_create
    @alert_trigger_type = AlertTriggerType.new
    @alert_trigger_type.name = 'test name'
    @alert_trigger_type.description = 'test description'
    @alert_trigger_type.method_name = 'test method'
    @alert_trigger_type.parameter_description = 'test parameter'
    @alert_trigger_type.save!
    @alert_trigger_type.reload
    assert_equal 'test name', @alert_trigger_type.name
    assert_equal 'test method', @alert_trigger_type.method_name
    assert_equal 'test parameter', @alert_trigger_type.parameter_description
    assert_equal 36, @alert_trigger_type.id.length
  end
  
  def test_update
    @alert_trigger_type = AlertTriggerType.new
    @alert_trigger_type.name = 'test name'
    @alert_trigger_type.description = 'test description'
    @alert_trigger_type.method_name = 'test method'
    @alert_trigger_type.parameter_description = 'test parameter'
    @alert_trigger_type.save!
    @alert_trigger_type.reload
    assert_equal 'test name', @alert_trigger_type.name
    assert_equal 'test method', @alert_trigger_type.method_name
    assert_equal 'test parameter', @alert_trigger_type.parameter_description
    
    @alert_trigger_type2 = AlertTriggerType.find_by_name('test name')
    assert_not_nil @alert_trigger_type2
    
    @alert_trigger_type2.name = 'new name'
    @alert_trigger_type2.method_name = 'new method'
    @alert_trigger_type2.description = 'new description'
    @alert_trigger_type2.parameter_description = 'new parameter'
    @alert_trigger_type2.save!
    @alert_trigger_type2.reload
    assert_equal 'new name', @alert_trigger_type2.name
    assert_equal 'new description', @alert_trigger_type2.description
    assert_equal 'new method', @alert_trigger_type2.method_name
    assert_equal 'new parameter', @alert_trigger_type2.parameter_description
    assert_equal @alert_trigger_type2.id, @alert_trigger_type.id
  end
end
