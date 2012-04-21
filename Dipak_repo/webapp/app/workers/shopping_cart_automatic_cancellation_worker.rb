class ShoppingCartAutomaticCancellationWorker

  @queue = :shopping_cart_automatic_cancellation
    def self.perform()
      shopping_cart = ShoppingCartLib.new()
      shopping_cart.make_changes_in_reim_for_failed_payment_user
    end 
end