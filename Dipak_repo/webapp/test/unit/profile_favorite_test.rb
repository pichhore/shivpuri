require File.dirname(__FILE__) + '/../test_helper'

class ProfileFavoriteTest < Test::Unit::TestCase
  def test_profile_delete_as_paranoid_should_delete_profile_favorites
    @profile = profiles(:buyer1)
    assert_not_nil @profile
    assert_equal 1, @profile.profile_favorites.length
    assert_equal 0, @profile.profile_favorites_to_me.length
    @profile.profile_favorites_to_me << create_favorite('owner1', @profile.id)
    assert_equal 1, @profile.profile_favorites_to_me.length
    @profile.destroy

    @not_deleted = ProfileFavorite.find(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileFavorite.find_with_deleted(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 1, @deleted.length

    @not_deleted = ProfileFavorite.find(:all, :conditions =>["target_profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileFavorite.find_with_deleted(:all, :conditions =>["target_profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 1, @deleted.length
  end

  protected

  def create_favorite(from_profile_id, to_profile_id)
    return ProfileFavorite.create({ :profile_id=>from_profile_id, :target_profile_id=>to_profile_id})
  end
end
