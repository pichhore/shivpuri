class AmpsMagnetResponderWorker
  @queue = :amps_magnet_responder
  def self.perform
    SellerMagnetResponder.process
  end 
end
