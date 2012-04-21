class SellerResponderSequence < ActiveRecord::Base
  uses_guid
  belongs_to :user
  has_many :seller_responder_sequence_mappings, :dependent => :destroy
  has_many :responder_sequence_assign_to_seller_profiles, :dependent => :destroy

  SEQUENCE_NAME = { "sequence_one" => "New Lead",  "sequence_two" => "Trying To Reach", "sequence_three" => "Next Steps", "sequence_four" => "Not Now", "do_not_call" => "Do Not Call","no_sequence" => "No Sequence"  ,"none" => "None", "amps_new" => "AMPS Hot Lead", "amps_cold" => "AMPS Cold Lead"}

  SEQUENCE_SERIES = { 1 => "sequence_one", 2 => "sequence_two", 3 => "sequence_three", 4 => "sequence_four", 5 => "do_not_call", 6 => "no_sequence", 7 => "amps_new", 8 => "amps_cold"}

  def self.get_seller_responder(user_id,sequence_id)
    seller_notification = SellerResponderSequence.find(:first,:conditions => ["user_id = ? and sequence_name LIKE ?",user_id,sequence_id])
    return seller_notification unless seller_notification.nil?
    return seller_notification = SellerResponderSequence.new()
  end

  def self.create_squence_and_assign_for_seller(user_id, sequence_id, property_id)
    seller_responder = SellerResponderSequence.find(:first,:conditions => ["user_id = ? and sequence_name LIKE ?",user_id,sequence_id])

    unless seller_responder
      seller_responder = SellerResponderSequence.create(:user_id => user_id, :sequence_name => sequence_id, :active => true)
    end

    seller_responder.responder_sequence_assign_to_seller_profiles.build({ :seller_property_profile_id => property_id, :mail_number => 1 }).save

    # ResponderSequenceAssignToSellerProfile.create(:seller_property_profile_id => property_id, :seller_responder_sequence_id => seller_responder.id, :mail_number => 1)
    return seller_responder
  end

  def self.create_squence_and_update_for_seller(user_id, sequence_id, property_id)
    seller_responder = SellerResponderSequence.find(:first,:conditions => ["user_id = ? and sequence_name LIKE ?",user_id,sequence_id])

    if seller_responder.blank?
      seller_responder = SellerResponderSequence.create(:user_id => user_id, :sequence_name => sequence_id, :active => true)
    end

    property = SellerPropertyProfile.find(property_id)
    if property
      property.responder_sequence_assign_to_seller_profile.update_attributes({:seller_responder_sequence_id => seller_responder.id, :mail_number => 1 })
    end

    return seller_responder
  end
end
