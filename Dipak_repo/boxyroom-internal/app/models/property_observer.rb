class PropertyObserver < ActiveRecord::Observer
  def after_update(property)

    # upon state changed
    if property.status_changed?

      if property.rejected?
        Delayed::Job.enqueue EmailJob.new(:deliver_rejected_listing_notification!, property)
        property.applications.reject_all!
      end

      if property.listed?
        Delayed::Job.enqueue EmailJob.new(:deliver_approved_listing_notification!, property)
      end

      if property.paid?
        Delayed::Job.enqueue EmailJob.new(:deliver_payment_received_notification!, property.applications.find_by_status("paid"))
      end

      if property.occupied?
        Delayed::Job.enqueue EmailJob.new(:deliver_payment_transferred_notification_to_landlord!, property.applications.find_by_status("moved_in"))
      end

      if property.withdraw_pending?
        Delayed::Job.enqueue EmailJob.new(:deliver_token_received_notification_to_admin!, property.applications.find_by_status("paid"))
        Delayed::Job.enqueue EmailJob.new(:deliver_token_received_notification_to_landlord!, property.applications.find_by_status("paid"))
      end
#       if property.occupied_?(payment_token)
#         
#       end

      if property.delisted?
        property.applications.reject_all!
      end
    end
  end
end
