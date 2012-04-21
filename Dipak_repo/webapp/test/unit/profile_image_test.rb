require File.dirname(__FILE__) + '/../test_helper'

class ProfileImageTest < Test::Unit::TestCase

  def test_profile_delete_as_paranoid_should_delete_profile_images
    @profile = profiles(:buyer1)
    assert_not_nil @profile
    @profile.profile_images << create_profile_image
    @profile.profile_images << create_profile_image
    @profile.profile_images << create_profile_image
    @profile.save!
    assert_equal 3, @profile.profile_images.length
    @profile.destroy

    @not_deleted = ProfileImage.find(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_equal 0, @not_deleted.length
    @deleted = ProfileImage.find_with_deleted(:all, :conditions =>["profile_id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal 3, @deleted.length
  end

  def create_profile_image
    return ProfileImage.new({ :content_type=>"image/jpeg", :size=>1000, :height=>10, :width=>10, :filename=>"fake.jpg" })
  end
end
