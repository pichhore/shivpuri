class MatchedLahShoppingCartUserWorker
  @queue = :match_lah_shopping_cart_user
    def self.perform(user_name, user_email, product_name, purchase_date)
      UserNotifier.deliver_send_match_lah_sc_user_notification(user_name, user_email, product_name, purchase_date)
    end 
end