require File.dirname(__FILE__) + '/../test_helper'
# require 'profile_observer'
include ActsAsXapian

class ProfileFieldEngineIndexTest < Test::Unit::TestCase
  fixtures :profile_field_engine_indices

  def setup
    # let this test suite set the profile name for quick lookup purposes
    Profile.skip_before_save = true
    ActsAsXapianJob.delete_all
  end
  
  def create_neighborhood
    ProfileFieldEngineIndex.delete_all

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'600000', :price_max=>'700000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer one'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78738,78734', :property_type=>'single_family', :beds=>'3', :baths=>'2', :square_feet_min=>'2000', :square_feet_max=>'2500', :price_min=>'300000', :price_max=>'700000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer two'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'2', :baths=>'2', :square_feet_min=>'1650', :square_feet_max=>'2500' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer three'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'acreage', :units_min=>'2', :units_max=>'4' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer four'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'multi_family', :acres_min=>'7' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer five'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'acreage', :acres_min=>'4' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer six'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'5', :baths=>'4', :square_feet=>'3300', :price=>'670000', :units=>'1', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner one'
    profile.user_id = users(:aaron).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'single_family', :beds=>'4', :baths=>'3', :square_feet=>'2300', :price=>'385000', :units=>'1', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner two'
    profile.user_id = users(:aaron).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'3', :square_feet=>'1700', :price=>'510000', :units=>'1', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner three'
    profile.user_id = users(:aaron).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'2', :baths=>'2', :square_feet=>'1300', :price=>'430000', :units=>'1', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner four'
    profile.user_id = users(:aaron).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78734', :property_type=>'multi_family', :beds=>'6', :baths=>'2', :square_feet=>'2500', :price=>'570000', :units=>'4', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner five'
    profile.user_id = users(:aaron).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'multi_family', :beds=>'6', :baths=>'2', :square_feet=>'2500', :price=>'570000', :units=>'8', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner six'
    profile.user_id = users(:aaron).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'acreage', :acres=>'5'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner seven'
    profile.user_id = users(:aaron).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'acreage', :acres=>'5'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner eight'
    profile.user_id = users(:inactive1).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!
    
    # set up favorites
    favorite = ProfileFavorite.new
    favorite.profile = Profile.find( :first, :conditions => [ "name = 'buyer two'" ] )
    favorite.target_profile = Profile.find( :first, :conditions => [ "name = 'owner one'" ] )
    favorite.save!

    favorite = ProfileFavorite.new
    favorite.profile = Profile.find( :first, :conditions => [ "name = 'buyer two'" ] )
    favorite.target_profile = Profile.find( :first, :conditions => [ "name = 'owner two'" ] )
    favorite.save!

    favorite = ProfileFavorite.new
    favorite.profile = Profile.find( :first, :conditions => [ "name = 'buyer two'" ] )
    favorite.target_profile = Profile.find( :first, :conditions => [ "name = 'owner three'" ] )
    favorite.save!

    # set up viewed
    viewed = ProfileView.new
    viewed.profile = Profile.find( :first, :conditions => [ "name = 'buyer two'" ] )
    viewed.viewed_by_profile = Profile.find( :first, :conditions => [ "name = 'owner one'" ] )
    viewed.save!

    viewed = ProfileView.new
    viewed.profile = Profile.find( :first, :conditions => [ "name = 'buyer two'" ] )
    viewed.viewed_by_profile = Profile.find( :first, :conditions => [ "name = 'owner two'" ] )
    viewed.save!

    viewed = ProfileView.new
    viewed.profile = Profile.find( :first, :conditions => [ "name = 'buyer two'" ] )
    viewed.viewed_by_profile = Profile.find( :first, :conditions => [ "name = 'owner three'" ] )
    viewed.save!
  end
  
  def test_create_simple_profile
    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet=>'3300', :price=>'670000', :units=>'1', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner one'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!    # this should trigger creation of engine index via observer mechanism

    pfei = ProfileFieldEngineIndex.find( :first, :conditions => [ "profile_id = ?", profile.id ] )

    assert_equal profile.field_value(:zip_code), pfei.zip_code
    assert_equal profile.field_value(:property_type), pfei.property_type
    assert_equal profile.field_value(:beds), pfei.beds.to_s
    assert_equal profile.field_value(:baths), pfei.baths.to_s
    assert_equal profile.field_value(:square_feet), pfei.square_feet.to_s
    assert_equal profile.field_value(:price), pfei.price.to_s
    assert_equal profile.field_value(:units), pfei.units.to_s
    assert_equal profile.field_value(:acres), pfei.acres.to_s

    assert_equal pfei.is_owner, true
  end
  
  def test_formatted_numbers_error
    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'4', 
      :square_feet=>'3,300', :price=>'670,000', :units=>'1', :acres=>'0'})
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner one'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!    # this should trigger creation of engine index via observer mechanism

    pfei = ProfileFieldEngineIndex.find( :first, :conditions => [ "profile_id = ?", profile.id ] )

    assert_equal profile.field_value(:zip_code), pfei.zip_code
    assert_equal profile.field_value(:property_type), pfei.property_type
    assert_equal profile.field_value(:beds), pfei.beds.to_s
    assert_equal profile.field_value(:baths), pfei.baths.to_s
    assert_equal 3300, pfei.square_feet
    assert_equal 670000, pfei.price
    assert_equal profile.field_value(:units), pfei.units.to_s
    assert_equal profile.field_value(:acres), pfei.acres.to_s

    assert_equal pfei.is_owner, true
  end

  def test_formatted_numbers_error_buyer
    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'3', :baths=>'2', 
      :square_feet_min=>'2,000', :square_feet_max=>'2,500', :price_min=>'300,000', :price_max=>'400,000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer two'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!    # this should trigger creation of engine index via observer mechanism

    pfei = ProfileFieldEngineIndex.find( :first, :conditions => [ "profile_id = ? && zip_code = ?", profile.id, '78738' ] )

    assert_equal '78738', pfei.zip_code

    assert_equal profile.field_value(:property_type), pfei.property_type
    assert_equal profile.field_value(:beds), pfei.beds.to_s
    assert_equal profile.field_value(:baths), pfei.baths.to_s
    assert_equal 2000, pfei.square_feet_min
    assert_equal 2500, pfei.square_feet_max
    assert_equal 300000, pfei.price_min
    assert_equal 400000, pfei.price_max
  end
  
  def test_create_multi_zip_profile
    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738,78734', :property_type=>'single_family', :beds=>'3', :baths=>'2', :square_feet_min=>'2000', :square_feet_max=>'2500', :price_min=>'300000', :price_max=>'400000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer two'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!    # this should trigger creation of engine index via observer mechanism

    pfei = ProfileFieldEngineIndex.find( :first, :conditions => [ "profile_id = ? && zip_code = ?", profile.id, '78738' ] )

    assert_equal '78738', pfei.zip_code

    assert_equal profile.field_value(:property_type), pfei.property_type
    assert_equal profile.field_value(:beds), pfei.beds.to_s
    assert_equal profile.field_value(:baths), pfei.baths.to_s
    assert_equal profile.field_value(:square_feet_min), pfei.square_feet_min.to_s
    assert_equal profile.field_value(:square_feet_max), pfei.square_feet_max.to_s
    assert_equal profile.field_value(:price_min), pfei.price_min.to_s
    assert_equal profile.field_value(:price_max), pfei.price_max.to_s

    assert_equal pfei.is_owner, false

    pfei = ProfileFieldEngineIndex.find( :first, :conditions => [ "profile_id = ? && zip_code = ?", profile.id, '78734' ] )

    assert_equal '78734', pfei.zip_code

    assert_equal profile.field_value(:property_type), pfei.property_type
    assert_equal profile.field_value(:beds), pfei.beds.to_s
    assert_equal profile.field_value(:baths), pfei.baths.to_s
    assert_equal profile.field_value(:square_feet_min), pfei.square_feet_min.to_s
    assert_equal profile.field_value(:square_feet_max), pfei.square_feet_max.to_s
    assert_equal profile.field_value(:price_min), pfei.price_min.to_s
    assert_equal profile.field_value(:price_max), pfei.price_max.to_s

    assert_equal pfei.is_owner, false
  end

  def test_quick_match_buyer
    create_neighborhood

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.BUYER, :zip_code => '78738' )

    assert matches.size == 3
    assert count == 3
    assert pages == 1
    # testing default sort order of privacy
    assert_equal "owner one", matches[0].name
    assert_equal "owner three", matches[1].name
    assert_equal "owner four", matches[2].name

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.BUYER, :zip_code => '78734' )

    assert_equal 4,matches.size
    assert count == 4
    assert pages == 1
    # testing default sort order of privacy
    assert_equal "owner two", matches[0].name
    assert_equal "owner six", matches[1].name
    assert_equal "owner seven", matches[2].name
    assert_equal "owner five", matches[3].name

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.BUYER, :zip_code => '78730' )

    assert matches.size == 0
    assert count == 0
    assert pages == 1
  end

  def test_quick_match_owner
    create_neighborhood

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.OWNER, :zip_code => '78738', :allow_duplicate_buyer_profiles=>true )

    assert_equal 3, matches.size
    assert count == 3
    assert pages == 1

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.OWNER, :zip_code => '78738', :number_to_fetch => 1, :offset => 0, :allow_duplicate_buyer_profiles=>true )

    # because number_to_fetch is set to one, only a single match of the three found is actually returned
    # and it requires three pages to deliver full results
    assert_equal 1, matches.size
    assert_equal 3, count
    assert_equal 3, pages

    # because offset is set to three, not even a single match of the three found is actually returned
    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.OWNER, :zip_code => '78738', :number_to_fetch => 1, :offset => 3, :allow_duplicate_buyer_profiles=>true )

    assert_equal 0, matches.size
    assert_equal 3, count
    assert_equal 3, pages

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.OWNER, :zip_code => '78734', :allow_duplicate_buyer_profiles=>true )

    assert_equal 4,matches.size
    assert count == 4
    assert pages == 1
    # testing default sort order of privacy and property type
    assert_equal "buyer five", matches[0].name
    assert_equal "buyer four", matches[1].name
    assert_equal "buyer six", matches[2].name
    assert_equal "buyer two", matches[3].name

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.OWNER, :zip_code => '78730', :allow_duplicate_buyer_profiles=>true )

    assert matches.size == 0
    assert count == 0
    assert pages == 1
  end

  def test_quick_match_owner_should_return_unique_only
    create_neighborhood

    # no zip code, should get a unique list of all buyers (but no duplicates for those with multiple zipcodes)
    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.OWNER, :allow_duplicate_buyer_profiles=>true )

    assert_equal 6, matches.size
    assert_equal 6, count
    assert_equal 1, pages
  end

  def test_quick_match_owner_should_return_only_one_profile_per_user
    # see Ticket #544

    # since the create_neighborhood helper doesn't associate all profiles to a user for testing purposes, we'll create some here
    ProfileFieldEngineIndex.delete_all
    Profile.delete_all

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'600000', :price_max=>'700000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer one'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78738,78734', :property_type=>'single_family', :beds=>'3', :baths=>'2', :square_feet_min=>'2000', :square_feet_max=>'2500', :price_min=>'300000', :price_max=>'700000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer two'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user_id = users(:quentin).id
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78734', :property_type=>'acreage', :units_min=>'2', :units_max=>'4' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer four'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user_id = users(:aaron).id
    profile.save!

    # no zip code, should get a single profile for quentin and the one for aaron
    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.OWNER )

    assert_equal 2, matches.size
    assert_equal 2, count
    assert_equal 1, pages
  end

  def test_match_buyer_one
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer one' ] )
    assert_not_nil profile
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_match_buyer_two
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 2
    assert count == 2
    assert pages == 1

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :number_to_fetch => 1, :offset => 0 )

    # because number_to_fetch is set to one, only a single match of the two found is actually returned
    # and it requires two pages to deliver full results
    assert_equal 1, matches.size
    assert_equal 2, count
    assert_equal 2, pages

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :number_to_fetch => 1, :offset => 2 )

    # because offset is set to two, not even a single match of the two found is actually returned
    assert matches.size == 0
    assert count == 2
    assert pages == 2
  end

  def test_match_buyer_three
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer three' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 2
    assert count == 2
    assert pages == 1
  end

  def test_match_buyer_four
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer four' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_match_buyer_five
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer five' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 0
    assert count == 0
    assert pages == 1
  end

  def test_match_buyer_six
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer six' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_match_owner_one
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 3
    assert count == 3
    assert pages == 1

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :number_to_fetch => 1, :offset => 0 )

    # because number_to_fetch is set to one, only a single match of the three found is actually returned
    # and it requires three pages to deliver full results
    assert_equal 1, matches.size
    assert_equal 3, count
    assert_equal 3, pages

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :number_to_fetch => 1, :offset => 3 )

    # because offset is set to three, not even a single match of the three found is actually returned
    assert matches.size == 0
    assert count == 3
    assert pages == 3
  end

  def test_match_owner_two
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_match_owner_three
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner three' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_match_owner_four
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner four' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 0
    assert count == 0
    assert pages == 1
  end

  def test_match_owner_five
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner five' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_match_owner_six
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner six' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert_equal 1, matches.size
    assert count == 1
    assert pages == 1
  end

  def test_match_owner_seven
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner seven' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert_equal 2, matches.size
    assert count == 2
    assert pages == 1
  end

  def test_match_favorites
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :favorites )

    assert matches.size == 3
    assert count == 3
    assert pages == 1

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :favorites, :number_to_fetch => 1, :offset => 0 )

    # because number_to_fetch is set to one, only a single match of the three found is actually returned
    # and it requires three pages to deliver full results
    assert matches.size == 1
    assert count == 3
    assert pages == 3

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :favorites, :number_to_fetch => 1, :offset => 3 )

    # because offset is set to three, not even a single match of the three found is actually returned
    assert matches.size == 0
    assert count == 3
    assert pages == 3

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer one' ] )
    assert_not_nil profile
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :favorites)

    assert matches.size == 0
    assert count == 0
    assert pages == 1
  end

  def test_match_viewed_me
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :viewed_me )

    assert matches.size == 3
    assert count == 3
    assert pages == 1

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :viewed_me, :number_to_fetch => 1, :offset => 0 )

    # because number_to_fetch is set to one, only a single match of the three found is actually returned
    # and it requires three pages to deliver full results
    assert matches.size == 1
    assert count == 3
    assert pages == 3

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :viewed_me, :number_to_fetch => 1, :offset => 3 )

    # because offset is set to three, not even a single match of the three found is actually returned
    assert matches.size == 0
    assert count == 3
    assert pages == 3

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer one' ] )
    assert_not_nil profile
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :viewed_me )

    assert matches.size == 0
    assert count == 0
    assert pages == 1
  end

  def test_match_new
    user = users(:quentin)

    # simulate previous login before creating neighborhood
    user.previous_login_at = Time.now.utc
    user.save!

    # insure at least one second elapses before creating profiles (all profiles will be new)
    sleep 1
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer one' ] )
    assert_not_nil profile
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :new )

    assert matches.size == 1
    assert count == 1
    assert pages == 1

    # simulate subsequent login (no profiles will be new)
    user.previous_login_at = Time.now.utc
    user.save!

    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :new)

    assert matches.size == 0
    assert count == 0
    assert pages == 1
  end

  def test_match_new_not_on_updated_profiles
    user = users(:quentin)

    # create the neighborhood
    create_neighborhood

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer one' ] )
    assert_not_nil profile
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :new )

    assert matches.size == 1
    assert count == 1
    assert pages == 1

    # simulate subsequent login (no profiles will be new)
    user.previous_login_at = Time.now.utc
    user.save!

    # verify that the current profiles are not considered new
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :new )

    assert matches.size == 0
    assert count == 0
    assert pages == 1

    sleep 1

    # update a profile
    profile2 = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )
    assert_not_nil profile2
    profile2.updated_at = Time.now.utc
    profile2.save!

    assert profile2.updated_at > user.previous_login_at
    assert profile2.created_at < user.previous_login_at

    # verify that the updated profile is not considered new
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :result_filter => :new )

    assert_equal 0, matches.size
    assert count == 0
    assert pages == 1

  end

  def test_edit_buyer_profile
    create_neighborhood

    # establish baseline
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 3
    assert count == 3
    assert pages == 1

    # change criteria for one matching buyer
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )

    # change zip code
    profile.profile_fields.each do |pf|
      if( pf.key.eql? 'zip_code' ) then
        pf.value_text = '78613'
        pf.save!
        break
      end
    end

    # trigger observer
   profile.save!

    # now check results
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 2
    assert count == 2
    assert pages == 1
  end

  def test_remove_buyer_profile
    create_neighborhood

    # establish baseline
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 3
    assert count == 3
    assert pages == 1

    # remove one matching buyer
    Profile.destroy( Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] ).id )

    # now check results
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 2
    assert count == 2
    assert pages == 1
  end

  def test_edit_owner_profile
    create_neighborhood

    # establish baseline
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 2
    assert count == 2
    assert pages == 1

    # change criteria for one matching owner
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )

    # change zip code
    profile.profile_fields.each do |pf|
      if( pf.key.eql? 'zip_code' ) then
        pf.value_text = '78613'
        pf.save!
        break
      end
    end

    # trigger observer
   profile.save!

    # now check results
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_remove_owner_profile
    create_neighborhood

    # establish baseline
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 2
    assert count == 2
    assert pages == 1

    # remove one matching owner
    Profile.destroy( Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] ).id )

    # now check results
    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer two' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 1
    assert count == 1
    assert pages == 1
  end

  def test_50_zip_profile
    create_50_different_zip_profiles

    profile = Profile.find( :first, :conditions => [ 'name = ?', 'buyer 50' ] )
    matches, count, pages = MatchingEngine.get_matches( :profile => profile, :number_to_fetch => 100 )

    assert_equal 50, matches.size
    assert_equal 50, count
    assert_equal 1, pages
  end

  def test_double_comma_problem
    ProfileFieldEngineIndex.delete_all

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78613', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet=>'3300', :price=>'850000' })
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner double-comma 78613'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user_id = users(:quentin).id
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78764', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet=>'3300', :price=>'850000' })
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner double-comma 78764'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user_id = users(:quentin).id
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78728', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet=>'3300', :price=>'850000' })
    profile = Profile.new
    profile.profile_type = ProfileType.OWNER
    profile.name = 'owner double-comma 78728'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user_id = users(:quentin).id
    profile.save!

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78613,78764,,78728', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'800000', :price_max=>'900000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer double-comma'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user_id = users(:aaron).id
    profile.save!

    matches, count, pages = MatchingEngine.get_matches( :profile => profile )

    assert matches.size == 3  # 3 total users, 1 is in-active
    assert count == 3
    assert pages == 1
  end



  def test_has_profile_image_should_be_false
    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'600000', :price_max=>'700000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer one'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.save!

    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert !index[0].has_profile_image
  end

  def test_has_profile_image_should_be_true
    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78738', :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'600000', :price_max=>'700000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer one'
    profile.user_id = users(:quentin).id
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.profile_images << ProfileImage.new({ :content_type=>"image/jpeg", :size=>1000, :height=>10, :width=>10, :filename=>"fake.jpg" })
    profile.save!

    index = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", profile.id ] )
    assert_not_nil index
    assert_equal 1, index.length
    assert index[0].has_profile_image
  end


  def create_50_different_zip_profiles
    ProfileFieldEngineIndex.delete_all

    # create owners in 50 different zips
    50.times do |n|
      target_zip = 78701 + n

      profile_field_form = ProfileFieldForm.new
      profile_field_form.from_hash({ :privacy=>'public', :zip_code=>target_zip.to_s, :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet=>'3300', :price=>'850000', :units=>'1', :acres=>'0' })
      profile = Profile.new
      profile.profile_type = ProfileType.OWNER
      profile.name = 'owner ' + target_zip.to_s
      profile.profile_fields = profile_field_form.to_profile_fields
      profile.user_id = users(:quentin).id
      profile.save!
    end

    # create a buyer looking in all 50 zips
    target_zips = '78701'

    49.times do |n|
      target_zips += ',' + ( 78702 + n ).to_s
    end

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>target_zips, :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'800000', :price_max=>'900000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = 'buyer 50'
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user_id = users(:quentin).id
    profile.save!
  end

  def test_quick_match_inactive
    create_neighborhood

    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.BUYER, :zip_code => '78734' )
    assert_not_equal 0, matches.length
    assert_equal 0, matches.select {|profile| profile.name == "owner eight" }.length
    puts matches.collect { |profile| profile.name }
    matches, count, pages = MatchingEngine.quick_match( :profile_type => ProfileType.BUYER, :zip_code => '78734', :inactive=>true )
    assert_not_equal 0, matches.length
    puts ""
    puts matches.collect { |profile| profile.name }
    assert_equal 1, matches.select {|profile| profile.name == "owner eight" }.length
    
  end
  

end
