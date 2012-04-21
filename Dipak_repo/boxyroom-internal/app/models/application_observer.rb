class ApplicationObserver < ActiveRecord::Observer
  def after_create(application)
    Delayed::Job.enqueue EmailJob.new(:deliver_application_created_notification!, application.id)
    Delayed::Job.enqueue EmailJob.new(:deliver_new_application_notification!, application.id)
  end

  def after_update(application)

    # upon state changed
    if application.status_changed?

      if application.pending?
        Delayed::Job.enqueue EmailJob.new(:deliver_new_application_notification!, application)
      end

      if application.approved?
        Delayed::Job.enqueue EmailJob.new(:deliver_application_approved_notification!, application)
      end

      if application.paid?
        Delayed::Job.enqueue EmailJob.new(:deliver_payment_made_notification!, application)
      end

      if application.rejected?
        Delayed::Job.enqueue EmailJob.new(:deliver_application_rejected_notification!, application)
      end

      if application.refunded?
        Delayed::Job.enqueue EmailJob.new(:deliver_refund_made_notification!, application) # to owner
        Delayed::Job.enqueue EmailJob.new(:deliver_refund_received_notification!, application) # to tenant
      end

    end

  end
end
