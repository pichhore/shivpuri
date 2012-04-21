require "net/http"
require "uri"
require 'net/imap'
require "xmlsimple"

class ShoppingCartLib

  SHOPPING_CART_SUCCESSFUL_ORDER_SUBJECTS = ["Recurring order was placed for REI Technologies", "New Order was placed for REI Technologies", "New Order was placed for Love American Homes", "Recurring order was placed for Love American Homes"]
  SHOPPING_CART_FAILED_ORDER_SUBJECTS = ["Recurring order failed for REI Technologies", "New order failed for REI Technologies", "New order failed for Love American Homes", "Recurring order failed for Love American Homes"]
  SHOPPING_CART_EMAIL_SUBJECTS = SHOPPING_CART_SUCCESSFUL_ORDER_SUBJECTS + SHOPPING_CART_FAILED_ORDER_SUBJECTS
  MERCHANT_URL = "https://www.mcssl.com/API"
  MERCHANT_ID = { "shopping_cart" => "187322", "lah_shopping_cart" => "190165" }
  MERCHANT_KEY = { "shopping_cart" => "E9954D6100C34E109E99098FFB8167BF", "lah_shopping_cart" => "532d108f3512406a939696569b48a836" }
  PERFORM_ACTION_FOR_ORDER_PRICE = ["$49.00", "$97.00"]

  def initialize
    @logger=Logger.new("#{RAILS_ROOT}/log/shopping_cart_cancellations.log")
    @config = YAML.load_file("#{RAILS_ROOT}/config/shopping_cart_email_credential.yml")
  end

  def make_changes_in_reim_for_failed_payment_user
    imap = Net::IMAP.new(@config['host'], 993, true)
    imap.login(@config['username'], @config['password'])
    imap.select('Inbox')
    imap.uid_search(["NOT", "SEEN"]).each do |uid|
      begin
        @logger.info "=================="
        source = imap.uid_fetch(uid, ['RFC822']).first.attr['RFC822']
        mail = TMail::Mail.parse(source)
        next unless SHOPPING_CART_EMAIL_SUBJECTS.include?(mail.subject)

        user_email = get_detail_from_email_body(mail, "Email: ")
        order_id = get_detail_from_email_body(mail, "Order ID: ")
        failed_payment_date = get_detail_from_email_body(mail, "Date: ")
        order_price = get_detail_from_email_body(mail, "Grand Total").lstrip
        @logger.info "Mail Subject: #{mail.subject}"
        @logger.info "User Email: #{user_email},  Order ID: #{order_id}, Order Price: #{order_price}, Date: #{failed_payment_date}"

        next unless PERFORM_ACTION_FOR_ORDER_PRICE.include?(order_price)
        @user = User.find(:first, :conditions =>["email = ? or login = ?", user_email, user_email])
        if @user.blank?
          @logger.info "User Not Found In REIM with email: #{user_email}"
          Resque.enqueue(MisMatchedFailedShoppingCartUserWorker, user_email, order_id)
          next
        end
        #User don't access to REIM because of failed transaction
        if SHOPPING_CART_FAILED_ORDER_SUBJECTS.include?(mail.subject) and @user.is_user_have_access_to_reim
          @logger.info "User #{user_email} have Failed Payment"
          @user.update_attributes(:user_login_count_after_failed_payment=>0, :is_user_have_failed_payment=>true, :failed_payment_date => failed_payment_date, :is_user_have_access_to_reim => false)
          UserTransactionHistory.create(:user_id => @user.id, :transanction_detail => "Customer payment failed for #{order_price}")
          next
        else
          @logger.info "User #{user_email} have Successful Payment"          
        end
        #User have access to REIM because of succesful transaction
        if SHOPPING_CART_SUCCESSFUL_ORDER_SUBJECTS.include?(mail.subject)
          @user.update_attributes(:user_login_count_after_failed_payment=>nil, :is_user_have_failed_payment=>false, :is_user_have_access_to_reim=>true)
          
          UserTransactionHistory.create(:user_id => @user.id, :transanction_detail => "Customer payment successful for #{order_price}")
        end
        
      rescue Exception=>exp
        @logger.info " something went wrong "
        @logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"ShoppoingCartLib")
      end
    end
  end

  def get_order_by_token_id(shopping_cart_name, token_id)
    uri = URI.parse("#{MERCHANT_URL}/#{MERCHANT_ID[shopping_cart_name]}/Orders/#{token_id}")
    @order_detail = get_response(uri, MERCHANT_KEY[shopping_cart_name])
  end

  def get_client_detail(shopping_cart_name, client_id)
    uri = URI.parse("#{MERCHANT_URL}/#{MERCHANT_ID[shopping_cart_name]}/Clients/#{client_id}")
    @client_detail = get_response(uri, MERCHANT_KEY[shopping_cart_name])
  end

  def get_product_by_product_id(shopping_cart_name, product_id)
    uri = URI.parse("#{MERCHANT_URL}/#{MERCHANT_ID[shopping_cart_name]}/Products/#{product_id}")
    @product_detail = get_response(uri, MERCHANT_KEY[shopping_cart_name])
  end

  def get_user_company_info_detail(client_detail)
    address_one = client_detail["ClientInfo"][0]["Address1"].blank? ? "" : client_detail["ClientInfo"][0]["Address1"][0]
    business_phone = client_detail["ClientInfo"][0]["Phone"].blank? ? "" : client_detail["ClientInfo"][0]["Phone"][0]
    client_city = client_detail["ClientInfo"][0]["City"].blank? ? "" : client_detail["ClientInfo"][0]["City"][0]
    client_state = client_detail["ClientInfo"][0]["StateName"].blank? ? "" : client_detail["ClientInfo"][0]["StateName"][0]
    client_zip = client_detail["ClientInfo"][0]["Zip"].blank? ? "" : client_detail["ClientInfo"][0]["Zip"][0]
    return address_one, business_phone, client_city, client_state, client_zip
  end

private

  def get_response(uri, key)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = "<?xml version='1.0' encoding='UTF-8'?><Request><Key>#{key}</Key></Request>"
      response = http.request(request)
      return XmlSimple.xml_in(response.body)
    rescue Exception=>exp
      @logger.info " something went wrong "
      @logger.info " Error 1 : (#{exp.class}) #{exp.message.inspect} "
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"ShoppoingCartLib")
    end
  end

  def get_detail_from_email_body(mail, detail_info)
    return mail.body.to_s.split(detail_info)[1].to_s.split("\r")[0]
  end

end
