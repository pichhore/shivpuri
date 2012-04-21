class MatchedShoppingCartUserPurchasedOtherProductWorker
  @queue = :matched_sopping_cart_user_purchase_other_product
    def self.perform(user_name, user_email, product_name, purchase_date, product_id, customer_id)
      UserNotifier.deliver_send_matched_shopping_cart_user_purchase_other_product(user_name, user_email, product_name, purchase_date, product_id, customer_id)
    end 
end