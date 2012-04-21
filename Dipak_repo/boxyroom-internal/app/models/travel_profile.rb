class TravelProfile < Profile
  validates_presence_of :previous_destination, :message=>"Enter previous destination.",  :if => Proc.new{|f| f.check_value_type}
  validates_length_of :previous_destination, :maximum => 95, :allow_nil => true, :message=>"Previous destination must be less than 96 characters.", :if => Proc.new{|f| f.check_value_type}
  validates_length_of :next_destination, :maximum => 95, :allow_nil => true, :message=>"Next destination must be less than 96 characters.", :if => Proc.new{|f| f.check_value_type}  
  validates_presence_of :reason_for_moving, :allow_nil => true, :message=>"Enter Reason for Moving",  :if => Proc.new{|f| f.check_value_type}
  # reason_for_moving field must have more than 15 characters
  validates_length_of :reason_for_moving, :in => 16..255, :message=>"Reason for Moving must be more than 15 characters.",  :if => Proc.new{|f| f.check_value_type}
  def check_value_type
    value_type == "travel-profile" or value_type == "TravelProfile"
  end
end
