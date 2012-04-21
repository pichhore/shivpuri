require File.dirname(__FILE__) + '/../test_helper'
require 'profiles_controller'

# Re-raise errors caught by the controller.
class ProfilesController; def rescue_action(e) raise e end; end

class ProfilesControllerTest < Test::Unit::TestCase

  def setup
    @controller = ProfilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
  end

  def test_get_missing_id
    get :new
    assert_response :error
  end

  def test_get_new_owner
    get :new, :id=>'owner'
    assert_response :success
    assert_template 'new_owner'
  end

  def test_get_new_buyer
    get :new, :id=>'buyer'
    assert_redirected_to :action=>'new_buyer_zipselect'
  end

  def test_create_owner_profile_missing_user_fields
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'single_family'}), :id=>'owner'
    assert_response :success
    assert_template 'new_owner'
    @user = assigns(:user)
    assert_not_nil @user
    assert_equal 6, @user.errors.count
  end

  #
  # Owner Property Type tests
  #

  def test_create_owner_profile_single_family_duplicate
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'single_family',:property_address=>'1801 Test Street'}), :user=>default_user_hash, :id=>'owner'
    assert_response :success, "Response was #{@response.response_code}. Message: #{@response.body}"
    @fields = assigns(:fields)
    assert_not_nil @fields
    assert_equal 1, @fields.errors.count
    @profile_type = assigns(:profile_type)
    @profile = assigns(:profile)
    assert_not_nil @profile_type
    assert_nil @profile
  end

  def test_create_owner_profile_single_family_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'single_family'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_owner_profile_single_family_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'single_family', :property_address=>'180000 Test Street', :description=>"testing description", :feature_tags=>"testing features"}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_public
    assert_equal '180000-test-street-78613', @profile.permalink
    description_fields = @profile.profile_fields.select { |field| field.key == "description" }
    assert_equal 1, description_fields.length
    assert_equal "testing description", description_fields[0].value
    features_fields = @profile.profile_fields.select { |field| field.key == "feature_tags" }
    assert_equal 1, features_fields.length
    assert_equal "testing features", features_fields[0].value
  end

  def test_create_owner_profile_multi_family_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'multi_family', :units=>"4", :property_address=>'180000 Test Street'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_public
    assert_equal '180000-test-street-78613', @profile.permalink
  end

  def test_create_owner_profile_multi_family_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'multi_family', :units=>"4"}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_owner_profile_condo_townhome_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'condo_townhome', :property_address=>'180000 Test Street'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_public
    assert_equal '180000-test-street-78613', @profile.permalink
  end

  def test_create_owner_profile_condo_townhome_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'condo_townhome'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_owner_profile_acreage_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'acreage', :acres=>"2", :property_address=>'180000 Test Street'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_public
    assert_equal '180000-test-street-78613', @profile.permalink
  end

  def test_create_owner_profile_acreage_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'acreage', :acres=>"2"}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_owner_profile_vacant_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'vacant_lot', :property_address=>'180000 Test Street'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_public
    assert_equal '180000-test-street-78613', @profile.permalink
  end

  def test_create_owner_profile_vacant_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'vacant_lot'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_owner_profile_other_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'other'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_public
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_owner_profile_other_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'other'}), :user=>default_user_hash, :id=>'owner'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_owner_profile_other_description_is_not_saved
    post :create, :fields=>{:garage=>"", :acres=>"", :stories=>"", :water=>"", :price=>"875,000", :county=>"", :property_address=>"4818B Twin Valley Drive", :baths=>"3", :school_middle=>"", :zip_code=>"78731", :property_type=>"single_family", :units=>"", :school_elementary=>"", :other_description=>"", :description=>"", :feature_tags=>"", :school_high=>"", :beds=>"3", :neighborhood=>"Cat Mountain", :sewer=>"", :privacy=>"public", :condo_community_name=>"", :total_actual_rent=>"", :livingrooms=>"", :square_feet=>"2800", :other_feature_tags=>""}, :user=>default_user_hash, :id=>'owner'
    @fields = assigns(:fields)
    assert_redirected_to owner_created_new_user_url, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Fields messages: #{@fields.errors.full_messages}"
    assert_not_nil @fields
    assert_equal 0, @fields.errors.count
    @profile = assigns(:profile)
    assert_not_nil @profile
    assert_profile_public
    description_fields = @profile.profile_fields.select { |field| field.key == "description"}
    assert_not_nil description_fields
    assert_equal 1, description_fields.length
    tags_field = @profile.profile_fields.select { |field| field.key == "feature_tags"}
    assert_not_nil tags_field
    assert_equal 1, tags_field.length
    # 46?? assert_equal 24, @profile.profile_fields.length
  end


  #
  # Buyer Various Property Type tests
  #

  def test_create_buyer_profile_single_family_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'single_family'}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_public
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_multi_family_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'multi_family', :units_min=>"1", :units_max=>"4"}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_public
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_multi_family_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'multi_family', :units_min=>"1", :units_max=>"4"}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_condo_townhome_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'condo_townhome'}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_public
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_condo_townhome_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'condo_townhome'}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_acreage_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'acreage', :acres_min=>"2", :acres_max=>"2"}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_public
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_acreage_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'acreage', :acres_min=>"2", :acres_max=>"2"}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_vacant_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'vacant_lot'}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_public
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_vacant_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'vacant_lot'}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_other_public
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'public', :property_type=>'other'}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_public
    assert_equal @profile.id.to_url, @profile.permalink
  end

  def test_create_buyer_profile_other_private
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'other'}), :user=>default_user_hash, :id=>'buyer'
    assert_results
    assert_profile_private
    assert_equal @profile.id.to_url, @profile.permalink
  end

  #
  # Other tests
  #
  def test_create_buyer_profile_other_private_logged_in
    login(users("quentin"))
    user_count = User.find(:all).length
    user_profile_count = users("quentin").profiles.length
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'other'}), :user=>default_user_hash, :id=>'buyer'
    @profile = assigns(:profile)
    assert_redirected_to :controller=>"account", :action=>"add_buyer_created"
    @fields = assigns(:fields)
    assert_not_nil @fields
    assert_equal 0, @fields.errors.count
    @profile_type = assigns(:profile_type)
    assert_not_nil @profile_type
    assert_not_nil @profile
    assert_equal @profile.id.to_url, @profile.permalink
    @user = assigns(:user)
    assert_not_nil @user
    assert_equal user_profile_count+1, @user.profiles.length
    assert_profile_private
    assert_equal user_count, User.find(:all).length
  end

  def test_create_owner_profile_other_private_logged_in
    login(users("quentin"))
    user_count = User.find(:all).length
    user_profile_count = users("quentin").profiles.length
    post :create, :fields=>default_fields_hash.merge({ :privacy=>'private', :property_type=>'other'}), :user=>default_user_hash, :id=>'owner'
    @profile = assigns(:profile)
    #assert_redirected_to :controller=>"account", :action=>"add_owner_created"
    #assert_redirected_to :controller=>"profile_images", :new=>"true"
    assert_redirected_to profile_profile_images_path(@profile, :new=>"true")
    @fields = assigns(:fields)
    assert_not_nil @fields
    assert_equal 0, @fields.errors.count
    @profile_type = assigns(:profile_type)
    assert_not_nil @profile_type
    assert_not_nil @profile
    assert_equal @profile.id.to_url, @profile.permalink
    @user = assigns(:user)
    assert_not_nil @user
    assert_equal user_profile_count+1, @user.profiles.length
    assert_profile_private
    assert_equal user_count, User.find(:all).length
  end

  def test_should_update
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    assert_equal "3", @profile.field_value(:beds)
    assert_equal "2", @profile.field_value(:baths)
    post :update, :id=>@profile.id, :fields=>{ :beds=>'4', :privacy=>"public", :square_feet_min=>"1000", :square_feet_max=>"3000", :description=>"testing description", :feature_tags=>"testing features" }
    assert_redirected_to profile_url(@profile), "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Errors #{assigns(:fields).errors.full_messages}"
    @profile = Profile.find('buyer1')
    bed_fields = @profile.profile_fields.select { |field| field.key == "beds" }
    assert_equal 1, bed_fields.length
    assert_equal "4", bed_fields[0].value
    assert_equal "4", @profile.field_value(:beds)
    assert_equal "2", @profile.field_value(:baths)
    description_fields = @profile.profile_fields.select { |field| field.key == "description" }
    assert_equal 1, description_fields.length
    assert_equal "testing description", description_fields[0].value
    features_fields = @profile.profile_fields.select { |field| field.key == "feature_tags" }
    assert_equal 1, features_fields.length
    assert_equal "testing features", features_fields[0].value
  end

  def test_should_update_description_not_create_new_one
    login(users("quentin"))
    ProfileField.create!({ :profile_id=>'buyer1', :key=>"description", :value=>"fake", :value_text=>"fake"})
    @profile = Profile.find('buyer1')
    assert_equal "3", @profile.field_value(:beds)
    assert_equal "2", @profile.field_value(:baths)
    assert_equal "fake", @profile.field_value(:description)
    description_fields = @profile.profile_fields.select { |field| field.key == "description" }
    assert_equal 1, description_fields.length
    post :update, :id=>@profile.id, :fields=>{ :beds=>'4', :privacy=>"public", :square_feet_min=>"1000", :square_feet_max=>"3000", :description=>"testing description", :feature_tags=>"testing features" }
    assert_redirected_to profile_url(@profile), "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Errors #{assigns(:fields).errors.full_messages}"
    @profile = Profile.find('buyer1')
    description_fields = @profile.profile_fields.select { |field| field.key == "description" }
    assert_equal 1, description_fields.length
    assert_equal "testing description", description_fields[0].value
    assert_equal "testing description", description_fields[0].value_text
  end

  def test_destroy_should_show_confirm_if_reason_missing
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    post :destroy, :id=>@profile.id, :profile_form=>{ }
    assert_response :success
    assert_template "delete_confirm"
    assert_not_nil assigns(:profile_form)
    assert_equal 1, assigns(:profile_form).errors.length
  end

  def test_destroy_should_show_confirm_if_reason_missing_but_other_given
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    post :destroy, :id=>@profile.id, :profile_form=>{ :delete_reason=>"Fake reason"}
    assert_response :success
    assert_template "delete_confirm"
    assert_not_nil assigns(:profile_form)
    assert_equal 1, assigns(:profile_form).errors.length
  end

  def test_destroy_should_delete_profile
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    post :destroy, :id=>@profile.id, :profile_form=>{ :profile_delete_reason_id=>"sold_dwellgo" }
    assert_redirected_to :controller=>"account", :action=>"profiles"
    assert_not_nil assigns(:profile_form)
    assert_equal 0, assigns(:profile_form).errors.length
    @deleted_profile = Profile.find_with_deleted(@profile.id)
    assert_not_nil @deleted_profile
    assert_not_nil @deleted_profile.profile_delete_reason
    assert_not_nil @deleted_profile.deleted_at
    assert_nil @deleted_profile.permalink
  end

  def test_destroy_should_delete_profile_other_no_reason
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    post :destroy, :id=>@profile.id, :profile_form=>{ :profile_delete_reason_id=>"other" }
    assert_redirected_to :controller=>"account", :action=>"profiles"
    assert_not_nil assigns(:profile_form)
    assert_equal 0, assigns(:profile_form).errors.length
    @deleted_profile = Profile.find_with_deleted(@profile.id)
    assert_not_nil @deleted_profile
    assert_nil @deleted_profile.profile_delete_reason
    assert_nil @deleted_profile.delete_reason
    assert_not_nil @deleted_profile.deleted_at
    assert_nil @deleted_profile.permalink
  end

  def test_destroy_should_delete_profile_other_reason
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    post :destroy, :id=>@profile.id, :profile_form=>{ :profile_delete_reason_id=>"other", :delete_reason=>"Fake reason" }
    assert_redirected_to :controller=>"account", :action=>"profiles"
    assert_not_nil assigns(:profile_form)
    assert_equal 0, assigns(:profile_form).errors.length
    @deleted_profile = Profile.find_with_deleted(@profile.id)
    assert_not_nil @deleted_profile
    assert_nil @deleted_profile.profile_delete_reason_id
    assert_not_nil @deleted_profile.delete_reason
    assert_not_nil @deleted_profile.deleted_at
    assert_nil @deleted_profile.permalink
  end

  def test_destroy_should_delete_profile_with_other_profile_same_permalink_name
    @buyer2_profile = Profile.find('buyer2')
    Profile.connection.update("UPDATE profiles set permalink = 'buyer1' WHERE id = '#{@buyer2_profile.id}'")
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    post :destroy, :id=>@profile.id, :profile_form=>{ :profile_delete_reason_id=>"sold_dwellgo" }
    assert_redirected_to :controller=>"account", :action=>"profiles"
    assert_not_nil assigns(:profile_form)
    assert_equal 0, assigns(:profile_form).errors.length
    @deleted_profile = Profile.find_with_deleted(@profile.id)
    assert_not_nil @deleted_profile
    assert_not_nil @deleted_profile.profile_delete_reason
    assert_not_nil @deleted_profile.deleted_at
    assert_nil @deleted_profile.permalink
  end

  def test_mark_as_spam_succeeds
    spam_claim_count = SpamClaim.count
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    xhr :post, :mark_as_spam, :id=>@profile.id
    assert_response :success, "#{@response.body}"
    assert_equal spam_claim_count+1, SpamClaim.count
    @profile.reload
    assert @profile.marked_as_spam
    claim = SpamClaim.find(:all).last
    assert_equal users(:quentin).id, claim.created_by_user_id
    assert_equal @profile.id, claim.claim_id
    assert_equal 'Profile', claim.claim_type
    assert_equal 1, @emails.size
  end

  def test_mark_as_spam_requires_login
    spam_claim_count = SpamClaim.count
    @profile = Profile.find('buyer1')
    xhr :post, :mark_as_spam, :id=>@profile.id
    assert_redirected_to :controller=>"sessions"
  end

  def test_mark_as_spam_requires_profile_id
    spam_claim_count = SpamClaim.count
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    xhr :post, :mark_as_spam
    assert_response :error
  end

  def test_edit_private_display_name
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    xhr :get, :edit_private_display_name, :id=>@profile.id
    assert_response :success, "#{@response.body}"
    assert_template "edit_private_display_name"
  end

  def test_update_private_display_name_success
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    xhr :post, :update_private_display_name, :id=>@profile.id, :target_profile=>{ :private_display_name=>"foo"}
    assert_response :success
    @profile.reload
    assert_equal "foo", @profile.private_display_name
  end

  def test_update_private_display_name_error
    login(users("quentin"))
    @profile = Profile.find('buyer1')
    xhr :post, :update_private_display_name, :id=>@profile.id, :target_profile=>{ :private_display_name=>""}
    assert_response :success, "#{@response.body}"
    assert_template "edit_private_display_name"
  end

  protected

  def default_user_hash
    return { :first_name=>"first", :last_name=>"last", :email=>"foo@bar.com", :password=>"foobar", :password_confirmation=>"foobar" }
  end

  def default_fields_hash
    return {:stories=>'1', :zip_code=>'78613', :property_type=>'single_family', :beds=>'3', :baths=>'2', :privacy=>'private', :square_feet=>'111', :price_min=>'1', :price_max=>'2', :price=>'2000000', :square_feet_min=>'1', :square_feet_max=>'2'}
  end

  def assert_results
    @fields = assigns(:fields)
    @profile_type = assigns(:profile_type)
    assert_redirected_to owner_created_new_user_url, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Fields messages: #{@fields.errors.full_messages}" if @profile_type.owner?
    assert_redirected_to buyer_created_new_user_url, "Response was #{@response.response_code}. Message: #{@response.body[0..100]}. Fields messages: #{@fields.errors.full_messages}" if @profile_type.buyer?
    assert_not_nil @fields
    assert_equal 0, @fields.errors.count
    @profile = assigns(:profile)
    assert_not_nil @profile_type
    assert_not_nil @profile
    @user = assigns(:user)
    assert_not_nil @user
    assert_equal 0, @user.errors.count
    assert_not_nil @profile.user_id
    assert_equal @user.id, @profile.user_id
  end

  def assert_profile_private
    assert_profile_is "private"
  end

  def assert_profile_public
    assert_profile_is "public"
  end

  def assert_profile_is(privacy)
    # verify straight from the DB
    @profile.reload
    assert_equal 1, @profile.profile_fields.select { |field| field.key == 'privacy' && field.value == privacy}.length
  end
  
  def test_profile_find_prev_next_profiles
    create_neighborhood

    @profile = Profile.find( :first, :conditions => [ 'name = ?', 'owner one' ] )
    # check starting state
    assert_not_nil @profile
    profiles, count, total_pages = MatchingEngine.get_matches(:profile=>@profile, :result_filter=>:all)
    #profile_ids.each_with_index do |profile_id, index|
    #  puts "#{index} - #{profile_id}"
    #end
    assert_equal 3, count
    assert_equal 3, profiles.length
    
    ac = ApplicationController.new
    @target_profile = profiles[0]
    params = { :page_number=>1 }
    prev_id, next_id = ac.find_prev_next_profile_ids(params, false)
    assert_nil prev_id
    assert_not_nil next_id
    assert_equal profile_ids[1], next_id
    
    @target_profile = profiles[1]
    prev_id, next_id = ac.find_prev_next_profile_ids(params, false)
    assert_not_nil prev_id
    assert_not_nil next_id
    assert_equal profile_ids[0], prev_id
    assert_equal profile_ids[2], next_id
    
    @target_profile = profiles[2]
    prev_id, next_id = @profile.find_prev_next_profile_ids(params,false)
    assert_not_nil prev_id
    assert_nil next_id
    assert_equal profile_ids[1], prev_id
  end
end
