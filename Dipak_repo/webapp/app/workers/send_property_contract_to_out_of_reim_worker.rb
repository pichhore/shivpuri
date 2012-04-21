class SendPropertyContractToOutOfReimWorker
    @queue = :send_property_contract_to_out_of_reim
    def self.perform(email, contract_name)
       UserNotifier.deliver_send_property_contract_to_out_of_reim(email, contract_name)
    end 
end