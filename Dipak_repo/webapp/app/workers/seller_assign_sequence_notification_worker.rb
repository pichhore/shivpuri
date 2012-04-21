class SellerAssignSequenceNotificationWorker
  @queue = :seller_assign_sequence_notification
    def self.perform(seller_sequence_id, seller_profile_id)
      seller_profile = SellerProfile.find_by_id(seller_profile_id)
      seller_sequence = SellerResponderSequence.find_by_id(seller_sequence_id)
      notification_email =  SellerResponderSequenceMapping.get_seller_responder_sequence_notification(seller_sequence, "1", seller_sequence.sequence_name)
      UserNotifier.deliver_send_seller_responder_sequence_notification(notification_email, seller_profile, seller_profile.seller_property_profile[0])
    end 
end