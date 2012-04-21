class FeedbackSubmittedNotificationWorker
  @queue = :feedback_submitted_notification
    def self.perform(user_id , feedback_id)
      user = User.find_by_id (user_id)
      hdr = UserNotifier.getsendgrid_header(user)
      feedback = Feedback.find_by_id (feedback_id)
      UserNotifier.deliver_feedback_submitted(feedback, hdr.asJSON())
    end 
end