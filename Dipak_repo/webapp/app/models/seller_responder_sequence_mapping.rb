class SellerResponderSequenceMapping < ActiveRecord::Base
  uses_guid
  belongs_to :seller_responder_sequence

  named_scope :find_by_email_number, lambda { |email_number| { :conditions => ['email_number = ?', email_number] }}

  def self.get_seller_responder_sequence_notification(seller_responder,email_number,sequence_type)
    seller_notification = seller_responder.seller_responder_sequence_mappings.find_by_email_number(email_number)[0]
    return seller_notification unless seller_notification.nil?
    case sequence_type
      when "sequence_one"
        email_subject, email_body =  SellerResponderEmailTemplate::SEQUENCE_ONE_EMAIL_SUBJECT[email_number.to_i],SellerResponderEmailTemplate::SEQUENCE_ONE_EMAIL_BODY[email_number.to_i]
      when "sequence_two"
        email_subject, email_body =  SellerResponderEmailTemplate::SEQUENCE_TWO_EMAIL_SUBJECT[email_number.to_i],SellerResponderEmailTemplate::SEQUENCE_TWO_EMAIL_BODY[email_number.to_i]
      when "sequence_three"
        email_subject, email_body =  SellerResponderEmailTemplate::SEQUENCE_THREE_EMAIL_SUBJECT[email_number.to_i],SellerResponderEmailTemplate::SEQUENCE_THREE_EMAIL_BODY[email_number.to_i]
      when "sequence_four"
        email_subject, email_body =  SellerResponderEmailTemplate::SEQUENCE_FOUR_EMAIL_SUBJECT[email_number.to_i],SellerResponderEmailTemplate::SEQUENCE_FOUR_EMAIL_BODY[email_number.to_i]
      when "amps_new"
        email_subject, email_body =  SellerResponderEmailTemplate::AMPS_NEW_EMAIL_SUBJECT[email_number.to_i],SellerResponderEmailTemplate::AMPS_NEW_EMAIL_BODY[email_number.to_i]
      when "amps_cold"
        email_subject, email_body =  SellerResponderEmailTemplate::AMPS_COLD_EMAIL_SUBJECT[email_number.to_i],SellerResponderEmailTemplate::AMPS_COLD_EMAIL_BODY[email_number.to_i]
    end
    return SellerResponderSequenceMapping.new(:email_subject => email_subject, :email_body => email_body)
  end
end
