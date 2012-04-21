require File.dirname(__FILE__) + '/../test_helper'
require 'net/http'

class ProfileTest < Test::Unit::TestCase

  # turn off tx fixtures for this test, as prev tests are messing things up
  # the next test class will turn it back on, allowing tests to run faster
  self.use_transactional_fixtures = false

  def setup
    # reset this flag, in case some other test changed it for their purposes
    Profile.skip_before_save = false
  end

  def test_create
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.profile_type = ProfileType.BUYER
    @profile.name = "Name"
    @profile.profile_fields = profiles(:buyer1).profile_fields.clone
    @profile.save!
    @profile.reload
    assert_equal users(:quentin).first_name, @profile.name
    assert_equal 36, @profile.id.length # GUID
    assert_equal @profile.id.to_url, @profile.permalink # Permalink is guid unless privacy field is 'public'
    assert_not_nil @profile.created_at # Rails
    assert_not_nil @profile.updated_at # Rails
    assert_nil @profile.deleted_at # acts_as_paranoid
    assert_not_nil @profile.private_display_name
  end

  def test_delete_paranoid
    log_count = ActivityLog.count
    @profile = profiles(:buyer1)
    assert_not_nil @profile
    @profile.destroy
    begin
      @profile.reload
      raise "Reloaded a destroyed profile - should not be found"
    rescue => e
      # good
    end
    assert_nil @profile.permalink
    assert_equal log_count+1, ActivityLog.count
    assert_equal 'cat_prof_deleted', ActivityLog.find(:all).last.activity_category_id
    assert_not_nil ActivityLog.find(:all).last.description
    @deleted = Profile.find_with_deleted(:first, :conditions =>["id = ?",@profile.id])
    assert_not_nil @deleted
    assert_equal @profile.id, @deleted.id
    assert_not_nil @deleted.deleted_at
  end

  def test_undelete_with_cascade
    @profile = profiles(:buyer1)
    @profile.destroy
    @deleted = Profile.find_with_deleted(:first, :conditions =>["id = ?",@profile.id])
    @pfeis = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", @profile.id ] )
    assert_not_nil @deleted
    assert_equal @profile.id, @deleted.id
    assert_not_nil @deleted.deleted_at
    assert_equal 0, @pfeis.length

    @profile.undelete_with_cascade
    @undeleted = Profile.find(:first, :conditions =>["id = ?",@profile.id])
    @pfeis = ProfileFieldEngineIndex.find( :all, :conditions => [ "profile_id = ?", @profile.id ] )
    assert_not_nil @undeleted
    assert_equal @profile.id, @undeleted.id
    assert_nil @undeleted.deleted_at
    assert @pfeis.length > 0
  end

  def test_field_value_found
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.profile_fields = @profile_field_form.to_profile_fields
    assert_equal "78613", @profile.field_value(:zip_code)
  end

  def test_field_value_not_found
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.profile_fields = @profile_field_form.to_profile_fields
    assert_equal nil, @profile.field_value(:not_there)
  end

  def test_permalink_generation_owner_private
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.name = "Name"
    @profile.profile_fields = @profile_field_form.to_profile_fields
    @profile.profile_type = ProfileType.OWNER
    @profile.save!
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_permalink_generation_owner_public
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.name = "Name"
    @profile.profile_fields = @profile_field_form.to_profile_fields
    @profile.profile_type = ProfileType.OWNER
    @profile.save!
    assert_equal "name", @profile.permalink
  end

  def test_permalink_generation_buyer_private
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.name = "Name"
    @profile.profile_fields = @profile_field_form.to_profile_fields
    @profile.profile_type = ProfileType.BUYER
    @profile.save!
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_permalink_generation_buyer_public
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'public', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.name = "Name"
    @profile.profile_fields = @profile_field_form.to_profile_fields
    @profile.profile_type = ProfileType.BUYER
    @profile.save!
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_property_type_methods
    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'single_family'}).to_profile_fields
    assert @profile.property_type_single_family?

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'multi_family'}).to_profile_fields
    assert @profile.property_type_multi_family?

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'condo_townhome'}).to_profile_fields
    assert @profile.property_type_condo_townhome?

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'vacant_lot'}).to_profile_fields
    assert @profile.property_type_vacant_lot?

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'acreage'}).to_profile_fields
    assert @profile.property_type_acreage?

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'other'}).to_profile_fields
    assert @profile.property_type_other?
  end

  def test_display_property_type
    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'single_family'}).to_profile_fields
    assert_equal "Single Family Home", @profile.display_property_type

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'multi_family'}).to_profile_fields
    assert_equal "Multi Family Home", @profile.display_property_type

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'condo_townhome'}).to_profile_fields
    assert_equal "Condo/Townhome", @profile.display_property_type

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'vacant_lot'}).to_profile_fields
    assert_equal "Vacant Lot", @profile.display_property_type

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'acreage'}).to_profile_fields
    assert_equal "Acreage", @profile.display_property_type

    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'other'}).to_profile_fields
    assert_equal "Other", @profile.display_property_type
  end

  def test_get_profile_field
    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'single_family'}).to_profile_fields
    assert_not_nil @profile.get_profile_field(:property_type)
    assert_equal "single_family", @profile.get_profile_field(:property_type).value
  end

  def test_set_profile_field
    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'single_family'}).to_profile_fields
    assert_not_nil @profile.get_profile_field(:property_type)
    @profile.set_profile_field(:property_type, "multi_family")
    assert_equal "multi_family", @profile.get_profile_field(:property_type).value
  end

  def test_geocoder_address_value
    @profile = Profile.new
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_address=>'1800 Test Street' }).to_profile_fields
    assert_equal nil, @profile.geocoder_address
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :zip_code=>'78613' }).to_profile_fields
    assert_equal nil, @profile.geocoder_address
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_address=>'1800 Test Street', :zip_code=>'78613' }).to_profile_fields
    assert_equal "1800 Test Street, 78613", @profile.geocoder_address
  end

  # NOTE: THIS TEST REQUIRES A VALID KEY FOR test IN gmaps_api_key.yml
  def test_geocoder_address_latlng_mechanism
    @profile = Profile.new
    @profile.name = "LatLng Test"
    @profile.profile_type = ProfileType.BUYER
    @profile.profile_fields = ProfileFieldForm.new.from_hash({ :property_type=>'single_family', :property_address=>'1 Congress Ave', :zip_code=>'78701' }).to_profile_fields

    assert_equal "1 Congress Ave, 78701", @profile.geocoder_address

    assert_nil @profile.field_value( :geo_ll )
    assert_nil @profile.field_value( :latlng )
    # These lat lng tests are a little flaky since google has added precision at least once (and some whitespace)
    # Use the following URL to double-check
    # http://maps.google.com/maps/geo?q=1+Congress+Ave,+78701&key=<your google maps api key>
    
    assert_equal "30.2625692,-97.7448548", @profile.latlng

    @profile.reload

    assert_equal @profile.geocoder_address, @profile.field_value( :geo_ll )
    assert_equal "30.2625692,-97.7448548", @profile.field_value( :latlng )
    assert_equal "30.2625692,-97.7448548", @profile.latlng
  end

  def test_name_regeneration_on_save_owner
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :property_address=>"1800 Ranch Way", :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.profile_fields = @profile_field_form.to_profile_fields
    @profile.profile_type = ProfileType.OWNER
    @profile.name = 'Name'
    @profile.save!
    assert_equal "(private), 78613", @profile.name

    @profile.reload
    @profile_privacy_fields = @profile.profile_fields.select { |field| field.key == "privacy"}
    assert_not_nil @profile_privacy_fields
    assert_equal 1,@profile_privacy_fields.length
    @profile_privacy_fields[0].value = "public"
    @profile_privacy_fields[0].save!
    @profile.save!
    @profile.reload
    assert_equal "1800 Ranch Way, 78613", @profile.name
  end


  def test_name_regeneration_on_save_buyer
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :property_address=>"1800 Ranch Way", :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description'})
    @profile = Profile.new
    @profile.user = users(:quentin)
    @profile.profile_fields = @profile_field_form.to_profile_fields
    @profile.profile_type = ProfileType.BUYER
    @profile.name = 'Name'
    @profile.save!
    assert_equal "quentin", @profile.name

    @profile.user.first_name = "New Name"
    @profile.user.save!

    @profile.reload
    assert_equal "New Name", @profile.name
  end

  def test_find_public_property_profiles
    @profiles = Profile.find_public_property_profiles
    assert_equal 2, @profiles.length # only 2 engine indices rows that we join to in our fixtures
    @profiles.each do |profile|
      assert profile.public_profile?
      assert (profile.owner? or profile.seller_agent?)
    end
  end

  def test_display_price_per_square_foot_empty_price
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :square_feet=>'1,000'})
    @profile = Profile.new
    @profile.profile_fields = @profile_field_form.to_profile_fields
    assert_equal "", @profile.display_price_per_square_foot
  end

  def test_display_price_per_square_foot_empty_square_feet
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :price=>"100,000"})
    @profile = Profile.new
    @profile.profile_fields = @profile_field_form.to_profile_fields
    assert_equal "", @profile.display_price_per_square_foot
  end

  def test_display_price_per_square_foot_with_commas
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :price=>"100,000", :square_feet=>'1,000'})
    @profile = Profile.new
    @profile.profile_fields = @profile_field_form.to_profile_fields
    assert_equal "$100", @profile.display_price_per_square_foot
  end
  
  def test_display_short_description
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :price=>"100,000", :description=>'Short description'})
    @profile = Profile.new
    @profile.profile_fields = @profile_field_form.to_profile_fields
    assert_equal "Short description...", @profile.display_description_short
  end
  
  def test_display_short_description_should_display_first_line
    @profile_field_form = ProfileFieldForm.new
    { 'line1' => 'line1...',
      'line2<br>line2<br>' => 'line2...',
      'line3<div>line2<div>' => 'line3...',
      'line4<p>line2<p>' => 'line4...',
      'line5<br/>' => 'line5...',
      'line6<strong>strong</strong><br>line2<div>' => 'line6<strong>strong</strong>...',
      '<div>line7</div>' => 'line7...',
      '<ul><li>line8</li><li>line9</li></ul>' => 'line8 line9...',
    }.each{ |key, value|
        @profile_field_form.from_hash({ :price=>"100,000", :description=>key})
        @profile = Profile.new
        @profile.profile_fields = @profile_field_form.to_profile_fields
        assert_equal value, @profile.display_description_short
      }
  end
  
  def test_display_short_description_should_truncate
    @profile_field_form = ProfileFieldForm.new
    { 'line1' => 'line1',
      'line2abcdefg' => 'line2a',
      'line3<br>' => 'line3',
      'line4abcdefg<br>' => 'line4a'
    }.each{ |key, value|
        @profile_field_form.from_hash({ :price=>"100,000", :description=>key})
        @profile = Profile.new
        @profile.profile_fields = @profile_field_form.to_profile_fields
        assert_equal value, @profile.rich_text_excerpt(key, 5)
      }
  end

end
