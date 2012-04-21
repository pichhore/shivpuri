require File.dirname(__FILE__) + '/../test_helper'

class FeaturedProfileTest < Test::Unit::TestCase

  def test_fixtures_loaded
    assert FeaturedProfile.count > 0
  end

  def test_find_buyers
    assert_equal 2, FeaturedProfile.find_buyers.length
  end

  def test_find_owners
    assert_equal 3, FeaturedProfile.find_owners.length
  end
end
