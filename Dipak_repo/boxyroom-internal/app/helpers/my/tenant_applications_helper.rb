module My::TenantApplicationsHelper
  OPTIONS_FOR_INCOME_SOURCE = {:employed => "Currently employed", :government => "Government assistance", :family => "Allowance from family", :none => "None", :others => "Others"}
  OPTIONS_FOR_NATURE_OF_EMPLOYMENT = {:full_time => "Full Time", :part_time => "Part Time", :casual => "Casual"}
  OPTIONS_FOR_IDENTIFICATION_TYPE = {:birth_certificate => "Birth Certificate", :drivers_license => "Driver's License", :identity_card => "Identity Card", :passport => "Passport", :others => "Others"}
  OPTIONS_FOR_CARD_TYPE = {:visa => "Visa", :master_card => "MasterCard", :discover => "Discover", :american_express => "American Express"}

  def options_for_income_source
    map = {}
    OPTIONS_FOR_INCOME_SOURCE.each do |key, value|
      map[value] = key.to_s
    end
    map
  end

  def options_for_nature_of_employment
    map = {}
    OPTIONS_FOR_NATURE_OF_EMPLOYMENT.each do |key, value|
      map[value] = key.to_s
    end
    map
  end

  def options_for_identification_type
    map = {}
    OPTIONS_FOR_IDENTIFICATION_TYPE.each do |key, value|
      map[value] = key.to_s
    end
    map
  end

  def options_for_card_type
    map = {}
    OPTIONS_FOR_CARD_TYPE.each do |key, value|
      map[value] = key.to_s
    end
    map
  end
end
