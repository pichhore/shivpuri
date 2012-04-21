require File.dirname(__FILE__) + '/../test_helper'

class ProfileFieldTest < Test::Unit::TestCase

  def test_profile_delete_as_paranoid_should_delete_profile_fields
    @profile = profiles(:buyer1)
    assert_not_nil @profile
    assert_equal 6, @profile.profile_fields.length
    @profile.destroy

    @not_deleted = ProfileField.find(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileField.find_with_deleted(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 6, @deleted.length
  end
end
