require "net/http"
require "uri"
require "xmlsimple"

class ShoppingCartController < ApplicationController
  skip_before_filter :verify_authenticity_token
  SHOPPING_CART_NAME_FOR_HASH = "shopping_cart"
  USERCLASS_BY_PRODUCT_NAME = {"7624346" => "UC1", "7624350" => "UC2"}
  PRODUCT_FOR_NEW_USER = ["8350512", "7624350", "8561968", "8630121"]
  PRODUCTS_FOR_EXISTING_USER = ["8350512", "7624350", "8350517", "7624346", "7624361", "8630121", "8630293","9035999"]
  MOVE_USER_TO_PLUS_SUBSCRIPTION = ["7624346", "8561968"]
  MOVE_USER_TO_PRO_SUBSCRIPTION = ["7624350", "8350512", "8350517", "8630121"]
  HOLD_SUBSCRIPTION_PRODUCT = ["8630293"]
  ADDITIONAL_TERRITORY_PRODUCT = ["7624361"]
  REIM_DEFAULT_PASS = "4reimatcher"
  SHOPPING_CART_NAME = "1Shopping Cart"
  DO_IT_FOR_YOU_PRODUCT = ["9035999"]

  def index
    begin
      # Write the code that will log all the params in a special log file  so that we know the params that shopping cart sends . Return after that as we dont need any processing to be done at the moment .
      shopping_cart_logfile = File.open("#{RAILS_ROOT}/log/shopping_cart_params.log", 'a')
      shopping_cart_logfile.sync = true
      shopping_cart_logger = ShoppingCartLogger.new(shopping_cart_logfile)
      shopping_cart_logger.debug params.to_yaml

      @shopping_cart_lib = ShoppingCartLib.new()

      render :text => "#{shopping_cart_logger.error "========Incorrect Params========\n"}" and return if params.to_s.split("<Token>")[1].nil?
      #retrieve the token_id from params getting by the notification url of shopping cart
      token_id = params.to_s.split("<Token>")[1].split("</Token>")[0]
      #get the order detail
      @order_detail = @shopping_cart_lib.get_order_by_token_id(SHOPPING_CART_NAME_FOR_HASH, token_id)
      #retrieve the client_id from order detail
      render :text => "#{shopping_cart_logger.error "========Not a valid token_id========\n"}" and return if @order_detail["success"] == "false"
      client_id = @order_detail["OrderInfo"][0]["ClientId"][0]["content"]
      #get the client detail
      @client_detail = @shopping_cart_lib.get_client_detail(SHOPPING_CART_NAME_FOR_HASH, client_id)
      params[:email] = @client_detail["ClientInfo"][0]["Email"][0]
      params[:customer_id] = client_id

      product_id = @order_detail["OrderInfo"][0]["LineItems"][0]["LineItemInfo"][0]["ProductId"][0]["content"]
      params[:product_id] = product_id
      #find user
      @user = User.find(:first, :conditions => ["email = ? or login =? ", @client_detail["ClientInfo"][0]["Email"][0], @client_detail["ClientInfo"][0]["Email"][0]])
      if @user.blank?
        if PRODUCT_FOR_NEW_USER.include?(product_id)
          create_new_user_in_reim(product_id)
          shopping_cart_detail = ShoppingCartUserDetail.create(:user_id => @new_user.id, :user_email => @new_user.email, :shopping_cart_name => SHOPPING_CART_NAME, :user_name => @new_user.first_name, :shopping_cart_customer_id_detail => client_id)
          
          UserTransactionHistory.create(:user_id => @new_user.id, :transanction_detail => "Customer purchased #{@order_detail["OrderInfo"][0]["LineItems"][0]["LineItemInfo"][0]["ProductName"][0]} product from  #{SHOPPING_CART_NAME}")
          
          render :text => "#{shopping_cart_logger.info "========User successfully created========\n user_email:- #{@client_detail["ClientInfo"][0]["Email"][0]}, Shopping Cart Product Id: #{product_id} and Shopping Cart Customer Id:- #{client_id} \n"}" and return
        end

        user = ShoppingCartUser.create(:first_name=> @client_detail["ClientInfo"][0]["FirstName"][0], :last_name => @client_detail["ClientInfo"][0]["LastName"][0], :email => @client_detail["ClientInfo"][0]["Email"][0], :product_name => @order_detail["OrderInfo"][0]["LineItems"][0]["LineItemInfo"][0]["ProductName"][0], :quantity => @order_detail["OrderInfo"][0]["LineItems"][0]["LineItemInfo"][0]["Quantity"][0])

        #sending notification email to support@reimatcher.com
        Resque.enqueue(MisMatchShoppingCartUserWorker, user.first_name + " " + user.last_name, user.email, user.product_name, @order_detail["OrderInfo"][0]["OrderDate"][0])
        render :text => "#{shopping_cart_logger.error "========User Not Found========\n user_email:- #{user.email} and Shopping Cart Customer Id:- #{client_id}, Shopping Cart Product Id: #{product_id} \n"}" and return
      end

          UserTransactionHistory.create(:user_id => @user.id, :transanction_detail => "Customer purchased #{@order_detail["OrderInfo"][0]["LineItems"][0]["LineItemInfo"][0]["ProductName"][0]} product from  #{SHOPPING_CART_NAME}")

      unless PRODUCTS_FOR_EXISTING_USER.include?(product_id)
        Resque.enqueue(MatchedShoppingCartUserPurchasedOtherProductWorker, @user.first_name + " " + @user.last_name, @user.email, @order_detail["OrderInfo"][0]["LineItems"][0]["LineItemInfo"][0]["ProductName"][0], @order_detail["OrderInfo"][0]["OrderDate"][0], product_id, client_id)
        render :text => "#{shopping_cart_logger.error "========User not updated========\n user_email:- #{@user.email} and Shopping Cart Customer Id:- #{client_id}, Shopping Cart Product Id: #{product_id} \n"}" and return
      end
      
      #User purchase hold subcription
      if HOLD_SUBSCRIPTION_PRODUCT.include?(product_id)
        if !@user.is_basic_user?
          user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:basic_type])
          @user.update_attributes(:user_class_id => user_class.id, :hold_offer => true, :is_user_have_failed_payment=>false, :is_user_have_access_to_reim => true)
          Resque.enqueue(UserCancelInReimWorker, @user.id, @user.full_name, "")
        else
          @user.update_attributes(:hold_offer => true)
        end
        render :text => "#{shopping_cart_logger.info "========User purchase Hold Subscription product========\n user_email:- #{@user.email} and Shopping Cart Customer Id:- #{client_id}, Shopping Cart Product Id: #{product_id} \n"}" and return
      end

      #User purchase do it for you
      if DO_IT_FOR_YOU_PRODUCT.include?(product_id)
        Icontact.add_user_to_your_site_done_for_you_list(@user,ICONTACT_HTTP_HEADER[:your_sites_done_for_you]) unless ICONTACT_HTTP_HEADER[:your_sites_done_for_you].blank?
        render :text => "#{shopping_cart_logger.info "========User purchase DO IT FOR YOU========\n user_email:- #{@user.email} and Shopping Cart Customer Id:- #{client_id}, Shopping Cart Product Id: #{product_id} \n"}" and return
      end

      #update user
      update_user_by_product(product_id)

      #track shopping cart name and shopping cart customer id
      if @user.shopping_cart_user_detail.find_by_shopping_cart_name(SHOPPING_CART_NAME).blank?
        shopping_cart_user_detail = ShoppingCartUserDetail.create(:user_id => @user.id, :user_email => @user.email, :shopping_cart_name => SHOPPING_CART_NAME, :user_name => @user.first_name, :shopping_cart_customer_id_detail => client_id)
      end

      shopping_cart_logger.info "==============="
      shopping_cart_logger.info " #{@user.email} purchased the product #{product_id} and Shopping Cart Customer Id is #{client_id} \n"

    rescue Exception => exp
      shopping_cart_logger.info " something went wrong "
      shopping_cart_logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      shopping_cart_logger.info " ============================= \n"
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    end
      render :text => "OK"
  end

private

  def create_new_user_in_reim(product_id)
    if MOVE_USER_TO_PLUS_SUBSCRIPTION.include?(product_id)
      user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:uc1_type])
    else
      user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:uc2_type])
    end

    @new_user = User.create(:login => @client_detail["ClientInfo"][0]["Email"][0], :email => @client_detail["ClientInfo"][0]["Email"][0], :first_name => @client_detail["ClientInfo"][0]["FirstName"][0], :last_name => @client_detail["ClientInfo"][0]["LastName"][0], :password => REIM_DEFAULT_PASS, :password_confirmation => REIM_DEFAULT_PASS, :user_class_id => user_class.id)

    #add company info for the user
    address_one, business_phone, client_city, client_state, client_zip = @shopping_cart_lib.get_user_company_info_detail(@client_detail)

    companyinfo = UserCompanyInfo.new(:business_name => 'Business Name', :business_address => address_one, :business_phone =>  business_phone, :business_email => @new_user.email, :city => client_city, :state => client_state, :zipcode => client_zip, :user_id => @new_user.id)
    companyinfo.save(false)
  end

  def update_user_by_product(product_detail)
    if ADDITIONAL_TERRITORY_PRODUCT.include?(product_detail)
      user_field = "number_of_territory"
      field_value = @user.number_of_territory.to_i + @order_detail["OrderInfo"][0]["LineItems"][0]["LineItemInfo"][0]["Quantity"][0].to_i
    elsif MOVE_USER_TO_PLUS_SUBSCRIPTION.include?(product_detail)
      user_field = "user_class_id"
      user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:uc1_type])
      field_value = user_class.id
    elsif MOVE_USER_TO_PRO_SUBSCRIPTION.include?(product_detail)
      user_field = "user_class_id"
      user_class = UserClass.find_by_user_type(BASIC_USER_CLASS[:uc2_type])
      field_value = user_class.id
    end
      update_user = @user.update_attributes(user_field => field_value)
  end

end
