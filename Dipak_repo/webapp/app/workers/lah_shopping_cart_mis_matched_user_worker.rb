class LahShoppingCartMisMatchedUserWorker
  @queue = :lah_shopping_cart_mis_match_user
    def self.perform(first_name, last_name, user_email, product_name, product_id, purchase_date)
      UserNotifier.deliver_send_lah_shopping_cart_mis_match_user(first_name, last_name, user_email, product_name, product_id, purchase_date)
    end 
end