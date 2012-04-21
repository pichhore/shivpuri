class DeletedProfile < ActiveRecord::Base
  set_table_name "profiles"
  belongs_to :profile_delete_reason
  validates_presence_of :profile_delete_reason_id, :message => "Please select a reason"
  before_save :triggered_before_save
  named_scope :get_deleted_profiles, lambda { |user_id| {:conditions => ["profile_delete_reason_id is not null and user_id = ?",user_id], :order => "deal_deleted_at DESC"}}

  def triggered_before_save
    self.delete_reason = nil if self.profile_delete_reason_id == "other_owner" or self.profile_delete_reason_id == "other_buyer"
  end  

  def owner?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b432-009096fa4c28")
  end

  def seller_agent?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b434-009096fa4c28")
  end

  def buyer?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b431-009096fa4c28")
  end

  def buyer_agent?
    return (self.profile_type_id and self.profile_type_id == "ce5c2320-4131-11dc-b433-009096fa4c28")
  end

end


  
