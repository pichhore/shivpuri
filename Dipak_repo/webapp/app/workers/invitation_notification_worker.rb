class InvitationNotificationWorker
  @queue = :invitation_notification
    def self.perform(user_id , invitation_id)
      user = User.find_by_id (user_id)
      hdr = UserNotifier.getsendgrid_header(user)
      invitation = Invitation.find_by_id (invitation_id)
      UserNotifier.deliver_invite(user, invitation)
    end 
end