class MessageObserver < ActiveRecord::Observer
  def after_create(message)
    Delayed::Job.enqueue EmailJob.new(:deliver_message!, message)
  end
end
