class MisMatchShoppingCartUserWorker
  @queue = :mis_match_shopping_cart_user
    def self.perform(user_name, user_email, product_name, purchase_date)
      UserNotifier.deliver_send_mis_match_user_notification(user_name, user_email, product_name, purchase_date)
    end 
end