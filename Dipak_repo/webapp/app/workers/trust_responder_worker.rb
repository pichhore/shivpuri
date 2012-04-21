class TrustResponderWorker
    @queue = :trust_responder
    def self.perform
      TrustResponderSetup.send_message()
    end 
end