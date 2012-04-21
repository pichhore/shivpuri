class SellerResponderWorker
    @queue = :seller_responder
    def self.perform
      SellerResponderSetup.send_message()
    end 
end