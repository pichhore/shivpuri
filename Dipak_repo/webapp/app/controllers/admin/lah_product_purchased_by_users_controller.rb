class Admin::LahProductPurchasedByUsersController < Admin::AdminController
  layout 'admin'

  def index
    @lah_product_purchased_by_users = LahProductPurchasedByUser.find(:all).paginate :page => params[:page], :per_page => 20
  end

end
