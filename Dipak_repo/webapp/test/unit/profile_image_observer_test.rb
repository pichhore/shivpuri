require File.dirname(__FILE__) + '/../test_helper'

class ProfileImageObserverTest < Test::Unit::TestCase

  def test_profile_engine_index_updated_on_first_profile_image
    profile = create_buyer_profile
    profile.save!
    assert_equal 0, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal false, index[0].has_profile_image

    profile.profile_images << create_profile_image
    assert_equal 1, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal true, index[0].has_profile_image
  end

  def test_profile_engine_index_still_true_for_second_image
    profile = create_buyer_profile
    profile.profile_images << create_profile_image
    profile.save!
    assert_equal 1, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal true, index[0].has_profile_image

    profile.profile_images << create_profile_image
    assert_equal 2, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal true, index[0].has_profile_image
  end

  def test_profile_engine_index_still_true_when_second_image_deleted
    profile = create_buyer_profile
    profile.profile_images << create_profile_image
    profile.profile_images << create_profile_image
    profile.save!
    assert_equal 2, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal true, index[0].has_profile_image

    profile.profile_images[1].destroy
    assert_equal 1, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal true, index[0].has_profile_image
  end

  def test_profile_engine_index_false_when_all_images_deleted
    profile = create_buyer_profile
    profile.profile_images << create_profile_image
    profile.profile_images << create_profile_image
    profile.save!
    assert_equal 2, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal true, index[0].has_profile_image

    profile.profile_images[1].destroy
    profile.profile_images[0].destroy
    assert_equal 0, profile.count_profile_images
    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert_equal false, index[0].has_profile_image
  end

  protected

  def create_buyer_profile
    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'600000', :price_max=>'700000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer one'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    return profile
  end

  def create_profile_image
    return ProfileImage.new({ :content_type=>"image/jpeg", :size=>1000, :height=>10, :width=>10, :filename=>"fake.jpg" })
  end

end
