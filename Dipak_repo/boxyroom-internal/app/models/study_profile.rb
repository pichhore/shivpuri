class StudyProfile < Profile

  # validations
  validates_presence_of :income_source, :message=> "Enter income source.", :if => Proc.new{|f| f.check_value_type}
#   validates_presence_of :student_no, :message=> "Enter student no.", :if => Proc.new{|f| f.check_value_type}
  validates_presence_of :weekly_income, :message=> "Enter weekly allowance.", :if => Proc.new{|f| f.check_value_type}

  validates_length_of :student_no, :maximum => 16, :allow_nil => true, :message=> "Student no must be less than 17 characters in Study Profile.", :if => Proc.new{|f| (f.check_value_type and !f.student_no.blank?)}

  validates_numericality_of :weekly_income, :greater_than => 0, :allow_nil => true, :message=> "Weekly income must be a number.", :if => Proc.new{|f| f.check_value_type}

  validates_inclusion_of :income_source, :in => My::TenantApplicationsHelper::OPTIONS_FOR_INCOME_SOURCE.map { |o| o.first.to_s }, :if => Proc.new{|f| f.check_value_type}

  validates_associated :guardian, :if => Proc.new{|f| f.check_value_type}

  def check_value_type
    value_type == "study-profile" or value_type == "StudyProfile"
  end

end
