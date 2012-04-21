require File.dirname(__FILE__) + '/../test_helper'

class ProfileMessageFormTest < Test::Unit::TestCase

  # turn off tx fixtures for this test, as prev tests are messing things up
  # the next test class will turn it back on, allowing tests to run faster
  self.use_transactional_fixtures = false

  def test_from_hash
    @profile_message_form = ProfileMessageForm.new
    assert_nil @profile_message_form.send_to
    @profile_message_form.from_hash({ :send_to=>['one','two','three']})
    assert_not_nil @profile_message_form.send_to
    assert_equal 3, @profile_message_form.send_to.length

    assert_nil @profile_message_form.filters
    @profile_message_form.from_hash({ :filters=>['one','two','three','four']})
    assert_not_nil @profile_message_form.filters
    assert_equal 4, @profile_message_form.filters.length

    assert_nil @profile_message_form.body
    @profile_message_form.from_hash({ :body=>'example'})
    assert_not_nil @profile_message_form.body
    assert_equal 'example', @profile_message_form.body
  end

  def test_validation
    @profile_message_form = ProfileMessageForm.new
    assert !@profile_message_form.valid?
    assert_equal 4, @profile_message_form.errors.length # added error for from_profile
    @profile_message_form.from_hash({ :send_to=>['one','two','three']})
    assert !@profile_message_form.valid?
    assert_equal 3, @profile_message_form.errors.length
    @profile_message_form.from_hash({ :subject=>'My message'})
    assert !@profile_message_form.valid?
    assert_equal 2, @profile_message_form.errors.length
    @profile_message_form.from_hash({ :body=>'example'})
    assert !@profile_message_form.valid?
    assert_equal 1, @profile_message_form.errors.length
    @profile_message_form.from_hash( { :from_profile_id=>'1'})
    assert @profile_message_form.valid?
    assert_equal 0, @profile_message_form.errors.length

    @profile_message_form.from_hash({ :send_to=>['indiv']})
    assert !@profile_message_form.valid?
    assert_equal 1, @profile_message_form.errors.length
    @profile_message_form.from_hash({ :indiv_profile_id=>'buyer1'})
    assert @profile_message_form.valid?
    assert_equal 0, @profile_message_form.errors.length
  end

  def test_to_profile_message_filter_by_all
    from_profile = profiles(:buyer1)
    @profile_message_form = ProfileMessageForm.new
    @profile_message_form.from_hash({ :send_to=>['all'], :filters=>['all'], :subject=>'My message', :body=>'Example message'})
    @profile_message = @profile_message_form.to_profile_message(from_profile)
    assert_not_nil @profile_message
    assert_equal @profile_message_form.body, @profile_message.body
    assert_equal 2, @profile_message.profile_message_recipients.length  # 3 total users, 1 is in-active
  end

  def test_to_profile_message_filter_by_indiv
    from_profile = profiles(:buyer1)
    @profile_message_form = ProfileMessageForm.new
    @profile_message_form.from_hash({ :send_to=>['indiv'], :indiv_profile_id=>'owner1', :subject=>'My message', :body=>'Example message'})
    @profile_message = @profile_message_form.to_profile_message(from_profile)
    assert_not_nil @profile_message
    assert_equal @profile_message_form.body, @profile_message.body
    assert_equal 1, @profile_message.profile_message_recipients.length
  end

  def test_to_profile_message_filter_by_all_more_than_10_matching_profiles
    from_profile = create_buyer_and_owner_extra_profiles

    @profile_message_form = ProfileMessageForm.new
    @profile_message_form.from_hash({ :send_to=>['all'], :filters=>['all'], :subject=>'My message', :body=>'Example message'})
    @profile_message = @profile_message_form.to_profile_message(from_profile)
    assert_not_nil @profile_message
    assert_equal @profile_message_form.body, @profile_message.body
    assert_equal 12, @profile_message.profile_message_recipients.length
  end

  protected


  def create_buyer_and_owner_extra_profiles(num_to_create=12)

    # create owners that will match buyer1
    target_zip = 78613
    num_to_create.times do |n|

      profile_field_form = ProfileFieldForm.new
      profile_field_form.from_hash({ :privacy=>'public', :zip_code=>target_zip.to_s, :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet=>'3300', :price=>'850000', :units=>'1', :acres=>'0' })
      profile = Profile.new
      profile.profile_type = ProfileType.OWNER
      profile.name = "owner #{n}" + target_zip.to_s
      profile.profile_fields = profile_field_form.to_profile_fields
      profile.user = users(:aaron)
      profile.save!
    end

    profile_field_form = ProfileFieldForm.new
    profile_field_form.from_hash({ :privacy=>'public', :zip_code=>target_zip.to_s, :property_type=>'single_family', :beds=>'4', :baths=>'4', :square_feet_min=>'3000', :square_feet_max=>'4000', :price_min=>'800000', :price_max=>'900000' })
    profile = Profile.new
    profile.profile_type = ProfileType.BUYER
    profile.name = "test buyer"
    profile.profile_fields = profile_field_form.to_profile_fields
    profile.user = users(:quentin)
    profile.save!
    return profile
  end

end
