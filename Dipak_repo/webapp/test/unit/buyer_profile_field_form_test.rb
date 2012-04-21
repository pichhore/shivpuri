require File.dirname(__FILE__) + '/../test_helper'

class BuyerProfileFieldFormTest < Test::Unit::TestCase

  def test_validation_basic
    @profile_field_form = BuyerProfileFieldForm.new
    assert !@profile_field_form.valid?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :privacy=>'private', :property_type=>'single_family'})
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :zip_code=>'7' })
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :zip_code=>'7abc3' })
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :zip_code=>'786139' })
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :zip_code=>'78613,' })
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :zip_code=>'78613,abcde' })
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :zip_code=>'78613' })
    assert @profile_field_form.valid?
    
    @profile_field_form.from_hash({ :zip_code=>'78613,78703,78704' })
    assert @profile_field_form.valid?
    assert_equal 0, @profile_field_form.errors.length
        
    @profile_field_form.from_hash({ :price_min=>'abc'})
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price_min=>'200000'})
    assert @profile_field_form.valid?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price_min=>'200,000'})
    assert @profile_field_form.valid?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price_max=>'def'})
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price_max=>'100000'})
    assert !@profile_field_form.valid?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price_max=>'400000'})
    assert @profile_field_form.valid?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price_max=>'400,000'})
    assert @profile_field_form.valid?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_does_not_require_property_address_unlike_owner_profile
    @profile_field_form = BuyerProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :beds=>2, :baths=>2, :square_feet_min=>'1450', :square_feet_max=>'1450'})
    assert @profile_field_form.valid_for_single_family?
  end

  def test_validation_single_family
    @profile_field_form = BuyerProfileFieldForm.new
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 4, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :beds=>'2'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 3, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :baths=>'2'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet_min=>'abc'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_min=>'2000'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_max=>'def'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_max=>'1000'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet_max=>'3000'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_multi_family
    
    @profile_field_form = BuyerProfileFieldForm.new
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 4, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet_min=>'abc'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 4, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_min=>'2000'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 3, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet_max=>'def'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_max=>'1000'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_max=>'3000'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :units_min=>'abc'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :units_min=>'12345'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :units_min=>'0'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :units_min=>'1234'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :units_max=>'def'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :units_max=>'54321'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :units_max=>'0'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :units_min=>'10'})
    @profile_field_form.from_hash({ :units_max=>'5'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :units_max=>'4321'})
    assert @profile_field_form.valid_for_multi_family?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_condo_townhome
    @profile_field_form = BuyerProfileFieldForm.new
    assert !@profile_field_form.valid_for_condo_townhome?
    assert_equal 4, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :beds=>'2'})
    assert !@profile_field_form.valid_for_condo_townhome?
    assert_equal 3, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :baths=>'2'})
    assert !@profile_field_form.valid_for_condo_townhome?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet_min=>'abc'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_min=>'2000'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_max=>'def'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet_max=>'1000'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet_max=>'3000'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_acreage
    @profile_field_form = BuyerProfileFieldForm.new
    assert !@profile_field_form.valid_for_acreage?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :acres_min=>'abc'})
    assert !@profile_field_form.valid_for_acreage?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :acres_min=>'5000'})
    assert !@profile_field_form.valid_for_acreage?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :acres_max=>'def'})
    assert !@profile_field_form.valid_for_acreage?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :acres_max=>'4000'})
    assert !@profile_field_form.valid_for_acreage?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :acres_max=>'5001'})
    assert @profile_field_form.valid_for_acreage?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_other
    @profile_field_form = BuyerProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy => 'private'})
    assert @profile_field_form.valid_for_other?
    assert_equal 0, @profile_field_form.errors.length
  end
end
