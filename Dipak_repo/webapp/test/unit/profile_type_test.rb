require File.dirname(__FILE__) + '/../test_helper'

class ProfileTypeTest < Test::Unit::TestCase

  def test_defaults
    assert_equal "buyer", profile_types(:buyer).permalink
    assert_equal "owner", profile_types(:owner).permalink
    assert_equal "buyer_agent", profile_types(:buyer_agent).permalink
    assert_equal "seller_agent", profile_types(:seller_agent).permalink
    assert_equal "service_provider", profile_types(:service_provider).permalink
  end

  def test_create
    @profile_type = ProfileType.new
    @profile_type.name = 'test name'
    @profile_type.save!
    @profile_type.reload
    assert_equal 'test name', @profile_type.name
    assert_equal 36, @profile_type.id.length
    assert_equal 'test-name', @profile_type.permalink
  end
end
