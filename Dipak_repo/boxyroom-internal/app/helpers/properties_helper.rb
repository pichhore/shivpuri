module PropertiesHelper

  OPTIONS_FOR_CATEGORY = {:whole_house=>"Whole House",:room_in_house=>"Room in house",:whole_apartment=>"Whole Apartment",:room_in_apartment=>"Room in apartment", :student_accommodation => "Student Accommodation"}
  # Define as an array to use in select, it doesn't change order of elements.
  OPTIONS_FOR_CATEGORY_SELECT=[ ["Whole House","whole_house"],["Room in House","room_in_house"],["Whole Apartment","whole_apartment"],["Room in Apartment","room_in_apartment"],["Student Accommodation","student_accommodation"] ]
  OPTIONS_FOR_UNIT = {:metric => "sq m", :imperial => "sq ft"}

  def options_for_category   
    map = {}
    OPTIONS_FOR_CATEGORY.each do |key, value|
      map[value] = key.to_s
    end
    map   
  end

  def options_for_unit
    map = {}
    OPTIONS_FOR_UNIT.each do |key, value|
      map[value] = key.to_s
    end
    map
  end

  def can_apply_for_property(property, &block)
    # if users are logged in, display the apply button anyway
    unless current_user.nil?
      return if current_user == property.owner
      return if property.status == 'pending'
      return if property.paid?
      return if property.occupied?
      return if current_user.applications.exists?(:property_id => property.id)
    end
    concat(capture(&block))
  end

  def can_display_in_dashboard(property, &block)
    return if current_user.nil?
    return if !property.paid? && !property.listed?
    if property.paid?
      return if property.paid_application.user != current_user
    end

    concat(capture(&block))
  end
  
  def property_picture_path(property)
    property.pictures.empty? ? "/images/missing/missing_properties_thumb.png" : property.pictures.first.image.url(:thumb)
  end
  
end
