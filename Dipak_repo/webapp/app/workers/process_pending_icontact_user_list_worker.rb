class ProcessPendingIcontactUserListWorker
    @queue = :process_pending_icontact_user
    def self.perform(limit,offset)
      Icontact.add_pending_user_to_icontact(limit,offset)
    end 
end