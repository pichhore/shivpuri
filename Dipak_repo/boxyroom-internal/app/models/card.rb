class Card < ActiveRecord::Base

  validates_presence_of :first_name, :message=>"Enter your first name."
  validates_presence_of :last_name, :message=>"Enter your last name."
#   validates_presence_of :email, :message=>"Enter your email"
#   validates_presence_of :mobile_no, :message=>"Enter your mobile number"
  validates_length_of :first_name, :within => 2..64, :message=>"First name must be more than 1 character."
  validates_length_of :last_name, :within => 2..64, :allow_nil => true, :message=>"Last name must be more than 1 character ."
  validates_length_of :email, :within => 2..128, :allow_nil => true, :message=>"Email must be more than 1 character ."
  validates_length_of :phone_no, :within => 5..16, :allow_nil => true, :message=>"Phone no must be more than 5 digits."
  validates_length_of :mobile_no, :within => 5..16, :allow_nil => true, :message=>"Mobile no must be more than 5 digits.",:unless => Proc.new { |a| a.mobile_no.blank? }
  validates_length_of  :fax_no, :within => 5..16, :allow_nil => true, :message=>"Fax no must be more than 5 digits.",:unless => Proc.new { |a| a.fax_no.blank? }
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message=>"Email address doesn't look correct."
  validates_format_of :first_name, :with => /^[-a-z-A-Z\d\s\_a_z_A_Z]*$/, :message => "Your first name must have characters [ 0-9, a-z, A-Z,  -,  _ ]."
  validates_format_of :last_name, :with => /^[-a-z-A-Z\d\s\_a_z_A_Z]*$/, :message=>"Your last name must have characters [ 0-9, a-z, A-Z,  -,  _ ]."
  validates_format_of :phone_no, :with =>  /\A[+-]?\d+\Z/, :message => "Phone no must be more than 5 digits."
  validates_format_of :mobile_no, :with =>  /\A[+-]?\d+\Z/, :message => "Mobile no must be more than 5 digits.",:unless => Proc.new { |a| a.mobile_no.blank? }
  validates_format_of :fax_no, :with =>  /\A[+-]?\d+\Z/, :message => "Fax no must be more than 5 digits.",:unless => Proc.new { |a| a.fax_no.blank? }
  
  def full_name
    "#{first_name} #{last_name.first}."
  end
end
