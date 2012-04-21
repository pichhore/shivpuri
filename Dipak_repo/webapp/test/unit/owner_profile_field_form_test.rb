require File.dirname(__FILE__) + '/../test_helper'

class OwnerProfileFieldFormTest < Test::Unit::TestCase

  def test_validation_basic
    @profile_field_form = OwnerProfileFieldForm.new
    assert !@profile_field_form.valid?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({:zip_code => 'abc'})
    assert !@profile_field_form.valid?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({:zip_code => '777'})
    assert !@profile_field_form.valid?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({:zip_code => '777777'})
    assert !@profile_field_form.valid?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({:zip_code => '77777'})
    assert !@profile_field_form.valid?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({:zip_code => '77777-123'})
    assert !@profile_field_form.valid?
    assert_equal 3, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({:zip_code => '77777-1234'})
    assert !@profile_field_form.valid?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form = OwnerProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family'})
    assert @profile_field_form.valid?
  end

  def test_validation_private_does_not_require_property_address
    @profile_field_form = OwnerProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'private', :zip_code=>'78613', :property_type=>'single_family', :beds=>'2', :baths=>'2', :square_feet=>'1450'})
    assert @profile_field_form.valid_for_single_family?
  end

  def test_validation_public_requires_property_address
    @profile_field_form = OwnerProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'public', :price=>"200000", :zip_code=>'78613', :property_type=>'single_family', :beds=>'2', :baths=>'2', :square_feet=>'1450'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :property_address=>'100'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :property_address=>'Somewhere'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :property_address=>'1000 S. Lamar'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :property_address=>'10 S/W Freeway, #221B'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :property_address=>'10, Rue De Vichyssoise'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :property_address=>"99 St. Mc'Donalds"})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
    
  end

  def test_validation_public_requires_price
    @profile_field_form = OwnerProfileFieldForm.new
    @profile_field_form.from_hash({ :privacy=>'public', :property_address=>"1000 S. Lamar", :zip_code=>'78613', :property_type=>'single_family', :beds=>'2', :baths=>'2', :square_feet=>'1450'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price=>'$200000'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price=>'200000'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price=>'200,000'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :price=>'negotiable'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length
  end

  def test_validation_single_family
    @profile_field_form = OwnerProfileFieldForm.new
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 3, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :beds=>'2'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :baths=>'2'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet=>'abc'})
    assert !@profile_field_form.valid_for_single_family?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet=>'2000'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet=>'2,000'})
    assert @profile_field_form.valid_for_single_family?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_multi_family
    @profile_field_form = OwnerProfileFieldForm.new
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 2, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet=>'abc'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet=>'2450'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet=>'2,000'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :units=>'abc'})
    assert !@profile_field_form.valid_for_multi_family?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :units=>'2' })
    assert @profile_field_form.valid_for_multi_family?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_condo_townhome
    @profile_field_form = OwnerProfileFieldForm.new
    assert !@profile_field_form.valid_for_condo_townhome?
    assert_equal 3, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :beds=>'2'})
    assert !@profile_field_form.valid_for_condo_townhome?
    assert_equal 2, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :baths=>'2'})
    assert !@profile_field_form.valid_for_condo_townhome?
    assert_equal 1, @profile_field_form.errors.length
    
   @profile_field_form.from_hash({ :square_feet=>'abc'})
    assert !@profile_field_form.valid_for_condo_townhome?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :square_feet=>'2450'})
    assert @profile_field_form.valid_for_condo_townhome?
    assert_equal 0, @profile_field_form.errors.length
    
    @profile_field_form.from_hash({ :square_feet=>'2,000'})
    assert @profile_field_form.valid_for_condo_townhome?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_acreage
    @profile_field_form = OwnerProfileFieldForm.new
    assert !@profile_field_form.valid_for_acreage?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :acres => 'abc'})
    assert !@profile_field_form.valid_for_acreage?
    assert_equal 1, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :acres => '2'})
    assert @profile_field_form.valid_for_acreage?
    assert_equal 0, @profile_field_form.errors.length

    @profile_field_form.from_hash({ :acres => '2,000'})
    assert @profile_field_form.valid_for_acreage?
    assert_equal 0, @profile_field_form.errors.length
  end

  def test_validation_other
    @profile_field_form = OwnerProfileFieldForm.new
    assert @profile_field_form.valid_for_other?
    assert_equal 0, @profile_field_form.errors.length
  end
end
