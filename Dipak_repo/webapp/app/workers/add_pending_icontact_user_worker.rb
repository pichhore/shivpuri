class AddPendingIcontactUserWorker
    @queue = :add_pending_icontact_user_to_list
    def self.perform
      Icontact.process_to_add_icontact_pending_user_in_list()
    end 
end