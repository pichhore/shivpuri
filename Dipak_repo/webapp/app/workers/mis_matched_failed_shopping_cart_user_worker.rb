class MisMatchedFailedShoppingCartUserWorker
  @queue = :mis_match_failed_shopping_cart_user
    def self.perform(user_email, order_id)
      UserNotifier.deliver_send_mismatched_failed_shopping_cart_user(user_email, order_id)
    end 
end