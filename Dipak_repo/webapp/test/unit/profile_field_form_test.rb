require File.dirname(__FILE__) + '/../test_helper'

class ProfileFieldFormTest < Test::Unit::TestCase
  fixtures :profile_types, :profiles, :profile_fields

  def test_from_hash
    @profile_field_form = ProfileFieldForm.new
    assert_nil @profile_field_form.privacy
    @profile_field_form.from_hash({ :privacy=>'private'})
    assert_not_nil @profile_field_form.privacy
    assert_equal 'private', @profile_field_form.privacy
  end

  def DISABLED_HACK_REMOVED_test_hack_from_hash_should_support_other_fields
    @profile_field_form = ProfileFieldForm.new
    assert_nil @profile_field_form.privacy
    @profile_field_form.from_hash({ :description=>'description', :other_description=>'other_description', :feature_tags=>'tags', :other_feature_tags=>'other_feature_tags'})
    assert_equal "description", @profile_field_form.description
    assert_equal "other_description", @profile_field_form.other_description
    assert_equal "tags", @profile_field_form.feature_tags
    assert_equal "other_feature_tags", @profile_field_form.other_feature_tags
  end

  def test_to_profile_fields
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'This is a short description', :feature_tags=>"tags"})
    assert @profile_field_form.valid?
    @fields = @profile_field_form.to_profile_fields
    assert_equal ProfileFieldForm.fields_array.length, @fields.length
    assert_equal 1, @fields.select { |field| field.key == 'description'}.length
    assert_equal @profile_field_form.description, @fields.select { |field| field.key == 'description'}[0].value
    assert_equal @profile_field_form.description, @fields.select { |field| field.key == 'description'}[0].value_text
    assert_equal 1, @fields.select { |field| field.key == 'feature_tags'}.length
    assert_equal @profile_field_form.feature_tags, @fields.select { |field| field.key == 'feature_tags'}[0].value
    assert_equal @profile_field_form.feature_tags, @fields.select { |field| field.key == 'feature_tags'}[0].value_text
  end

  def DISABLED_HACK_REMOVED_test_hack_other_fields_with_to_profile_fields
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'', :other_description=>'other_description', :feature_tags=>'', :other_feature_tags=>'other_feature_tags'})
    assert @profile_field_form.valid?
    @fields = @profile_field_form.to_profile_fields
    assert_equal ProfileFieldForm.fields_array.length-2, @fields.length
    assert_equal @profile_field_form.other_description, @fields.select { |field| field.key == 'description'}[0].value
    assert_equal @profile_field_form.other_description, @fields.select { |field| field.key == 'description'}[0].value_text
    assert_equal @profile_field_form.other_feature_tags, @fields.select { |field| field.key == 'feature_tags'}[0].value
    assert_equal @profile_field_form.other_feature_tags, @fields.select { |field| field.key == 'feature_tags'}[0].value_text

    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'description', :feature_tags=>'feature_tags'})
    assert @profile_field_form.valid?
    @fields = @profile_field_form.to_profile_fields
    assert_equal ProfileFieldForm.fields_array.length-2, @fields.length
    assert_equal @profile_field_form.description, @fields.select { |field| field.key == 'description'}[0].value
    assert_equal @profile_field_form.description, @fields.select { |field| field.key == 'description'}[0].value_text
    assert_equal @profile_field_form.feature_tags, @fields.select { |field| field.key == 'feature_tags'}[0].value
    assert_equal @profile_field_form.feature_tags, @fields.select { |field| field.key == 'feature_tags'}[0].value_text
  end

  def test_long_text_fields_should_have_shorter_value_field
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'A very very very very very very very very very very very very very very very very very very very very very long string', :feature_tags=>'tags'})
    assert @profile_field_form.valid?
    @fields = @profile_field_form.to_profile_fields
    @description = @fields.select { |field| field.key == 'description'}[0]
    @feature_tags = @fields.select { |field| field.key == 'feature_tags'}[0]
    assert_not_nil @description
    assert_equal @profile_field_form.description, @description.value_text
    assert_equal @profile_field_form.description[0..99], @description.value
    assert_equal 100, @description.value.length
    assert @description.value_text.length > 100
    assert_not_nil @feature_tags
    assert_equal @feature_tags.value.length, @feature_tags.value_text.length
  end

  def test_currency_fields_should_remove_comma_separators
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :description=>'description', :feature_tags=>'tags', :price=>'999999', :price_min=>'111111', :price_max=>'222222'})
    assert @profile_field_form.valid?
    @fields = @profile_field_form.to_profile_fields
    @price = @fields.select { |field| field.key == 'price'}[0]
    @price_min = @fields.select { |field| field.key == 'price_min'}[0]
    @price_max = @fields.select { |field| field.key == 'price_max'}[0]
    assert_equal '999999',@price.value
    assert_equal '111111',@price_min.value
    assert_equal '222222',@price_max.value
  end

  def test_merge_profile_fields_with_existing_entry
    @profile = Profile.find('buyer1')
    @beds = @profile.profile_fields.select { |field| field.key == 'beds'}[0]
    assert_equal "3", @beds.value
    starting_field_count = @profile.profile_fields.length
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :beds=>'4'})
    merged_profile = @profile_field_form.merge_profile_fields(@profile)
    assert_equal ProfileFieldForm.fields_array_count, merged_profile.profile_fields.length
    @beds = merged_profile.profile_fields.select { |field| field.key == 'beds'}[0]
    assert_not_nil @beds
    assert_equal "4", @beds.value
  end

  def test_merge_profile_fields_with_new_entry
    @profile = Profile.find('buyer1')
    @description = @profile.profile_fields.select { |field| field.key == 'description'}
    assert @description.empty?
    starting_field_count = @profile.profile_fields.length
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :description=>'new description'})
    merged_profile = @profile_field_form.merge_profile_fields(@profile)
    assert_equal ProfileFieldForm.fields_array_count, merged_profile.profile_fields.length
    @description = merged_profile.profile_fields.select { |field| field.key == 'description'}[0]
    assert_not_nil @description
    assert_equal "new description", @description.value_text
  end

  def test_merge_profile_fields_with_non_nil_value_to_nil
    @profile = Profile.find('buyer1')
    @beds = @profile.profile_fields.select { |field| field.key == 'beds'}[0]
    assert_equal "3", @beds.value
    starting_field_count = @profile.profile_fields.length
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ })
    merged_profile = @profile_field_form.merge_profile_fields(@profile)
    assert_equal ProfileFieldForm.fields_array_count, merged_profile.profile_fields.length
    @beds = merged_profile.profile_fields.select { |field| field.key == 'beds'}[0]
    assert_not_nil @beds
    assert_equal nil, @beds.value
  end

  def test_from_profile_fields
    @profile = Profile.find('buyer1')
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_profile_fields(@profile.profile_fields)
    @beds = @profile.profile_fields.select { |field| field.key == 'beds'}[0]
    assert_equal @beds.value, @profile_field_form.beds
  end

  def test_long_zip_code_field
    long_zip_code = Array.new
    78701.upto(78799) { |zip| long_zip_code << zip }
    long_zip_code_string = long_zip_code.join(",")

    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>long_zip_code_string, :property_type=>'single_family'})
    assert @profile_field_form.valid?
    @fields = @profile_field_form.to_profile_fields
    @zip_code = @fields.select { |field| field.key == 'zip_code'}[0]
    assert_not_nil @zip_code
    assert_equal @profile_field_form.zip_code, @zip_code.value_text
    assert_equal @profile_field_form.zip_code[0..99], @zip_code.value
    assert_equal 100, @zip_code.value.length
    assert @zip_code.value_text.length > 100
  end
  
  def test_rich_text_fields_should_remove_scripts
    @profile_field_form = ProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :feature_tags=>'tags', 
      :description=>'<script>this should not be here</script>'})
    assert @profile_field_form.valid?
    @fields = @profile_field_form.to_profile_fields
    @description = @fields.select { |field| field.key == 'description'}[0]
    assert_not_nil @description
    assert_equal '', @description.value_text
  end
  
  def test_rich_text_fields_should_remove_duplicate_breaks
    @profile_field_form = ProfileFieldForm.new
    { '1<br>' => '1<br>',
      '2<br/>' => '2<br/>',
      '3<br />' => '3<br />',
      '4<br><br>' => '4<br><br>',
      '5<br/><br>' => '5<br/><br>',
      '6<br/><br/>' => '6<br/><br/>',
      '7<br /><br/>' => '7<br /><br/>',
      '8<br /><br />' => '8<br /><br />',
      '9<br> <br />' => '9<br> <br />',
      'A<br>  <br/>  <br/>' => 'A<br/><br/>',
      'B<br>line1<br>line2<br><br>' => 'B<br>line1<br>line2<br><br>',
      'C<br><br><br>' => 'C<br/><br/>',
      'D<br/><br/><br/>' => 'D<br/><br/>',
      'E<br /><br><br/>' => 'E<br/><br/>',
      'F<br /><br><br/>  <br>   <br/>' => 'F<br/><br/>'
      }.each { |key, value|
      
        @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :feature_tags=>'tags', 
          :description=>key})
        @fields = @profile_field_form.to_profile_fields
        @description = @fields.select { |field| field.key == 'description'}[0]
        assert_equal value, @description.value_text
      }
  end

end
