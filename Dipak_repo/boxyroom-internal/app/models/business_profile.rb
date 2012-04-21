class BusinessProfile < Profile

  # validations
  validates_presence_of :company_name, :message=> "Enter your comapny name.", :if => Proc.new{|f| f.check_value_type}
  validates_presence_of  :industry, :message=> "Enter your industry.", :if => Proc.new{|f| f.check_value_type} 
  validates_presence_of :position, :message=> "Enter your position.", :if => Proc.new{|f| f.check_value_type} 
  validates_presence_of :nature_of_employment, :message=> "Enter nature of employment.", :if => Proc.new{|f| f.check_value_type}
  validates_length_of :company_name, :maximum => 64, :allow_nil => true, :message=> "Company name must be less than 65 characters .", :if => Proc.new{|f| f.check_value_type}
  validates_length_of :industry, :maximum => 64, :allow_nil => true, :message=> "Industry must be less than 65 characters .", :if => Proc.new{|f| f.check_value_type}
  validates_length_of :position, :maximum => 64, :allow_nil => true, :message=> "Position must be less than 65 characters.", :if => Proc.new{|f| f.check_value_type}
  validates_numericality_of :gross_annual_salary, :greater_than => 0, :allow_nil => true, :message=> "Gross annual salary must be greater than 0.", :if => Proc.new{|f| f.check_value_type and !f.gross_annual_salary.blank?}
  validates_inclusion_of :nature_of_employment, :in =>My::TenantApplicationsHelper::OPTIONS_FOR_NATURE_OF_EMPLOYMENT.map { |o| o.first.to_s }, :if => Proc.new{|f| f.check_value_type}
  #validates_date :end_of_employment, :before => Date.today
  validates_date :start_of_employment, :before => :end_of_employment, :before_message =>"Start of employment must be before End of employment.",:if => Proc.new{|f| f.check_value_type and !f.end_of_employment.blank?}
  validates_associated :superior, :if => Proc.new{|f| f.check_value_type}
  def check_value_type
    value_type == "business-profile" or value_type == "BusinessProfile"
  end

end
