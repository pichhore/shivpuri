require File.dirname(__FILE__) + '/../test_helper'

class ProfileViewTest < Test::Unit::TestCase
  def test_profile_delete_as_paranoid_should_delete_profile_favorites
    @profile = profiles(:buyer1)
    assert_not_nil @profile

    @profile.profile_viewed_by << create_profile_view(@profile.id, 'owner1')
    @profile.profile_viewed_me << create_profile_view('owner1', @profile.id)
    assert_equal 1, @profile.profile_viewed_me.length
    assert_equal 1, @profile.profile_viewed_by.length
    @profile.destroy

    @not_deleted = ProfileView.find(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileView.find_with_deleted(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 1, @deleted.length

    @not_deleted = ProfileView.find(:all, :conditions =>["viewed_by_profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileView.find_with_deleted(:all, :conditions =>["viewed_by_profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 1, @deleted.length
  end

  protected

  def create_profile_view(from_profile_id, to_profile_id)
    ProfileView.new({ :profile_id=>to_profile_id, :viewed_by_profile_id=>from_profile_id})
  end
end
