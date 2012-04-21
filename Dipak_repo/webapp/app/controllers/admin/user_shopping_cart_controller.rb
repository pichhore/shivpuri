class Admin::UserShoppingCartController < Admin::AdminController
  active_scaffold :shopping_cart_user do |config|
    list.columns = [:first_name, :last_name, :email, :product_name, :quantity, :created_at]
    config.actions.exclude :create, :update, :show, :delete
  end

end
