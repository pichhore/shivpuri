class PaymentsController < ApplicationController
  include ActiveMerchant::Billing
  before_filter :require_user
#   before_filter :property_status_check, :only =>[  :call_credit_card ]
  #TODO use declarative authorization here
  
  def index
  end

  def confirm
    redirect_to :action => 'index' unless params[:token]

    details_response = gateway.details_for(params[:token])

    if !details_response.success?
      @message = details_response.message
      render :action => 'error'
      return
    end

    @application = current_user.applications.find(session[:application_id])

    @response = details_response
    @address = details_response.address

    #render :layout=>"new/application"
    redirect_to  :action => 'complete', :token => params[:token], :payer_id => params[:PayerID] 

  end

  def complete
    @amount = session[:amount]

    @application = current_user.applications.find(session[:application_id])

    purchase = gateway.purchase(@amount,
      :ip => request.remote_ip,
      :payer_id => params[:payer_id],
      :token => params[:token],
      :currency => @application.property.currency_type)

    if !purchase.success?
      @message = purchase.message
      render :action => 'error'
      return
    else
#       @application.make_payment!
      flash[:notice]  = "Your payment has been accepted"
      payment_token = payment_token_generate
      @application.make_payment_!(@application,payment_token)
      redirect_to payment_notification_detail_my_application_path(@application)
    end

  end

  def checkout
    @application = current_user.applications.find(params[:id])
    @property = @application.property

    price_in_cents = @application.property.monthly_rental * 100

    session[:amount] = price_in_cents
    session[:application_id] = @application.id

    setup_response = gateway.setup_purchase(price_in_cents,
      :ip                   => request.remote_ip,
      :return_url           => url_for(:action => 'confirm', :only_path => false),
      :cancel_return_url    => my_application_url(@application),
      :currency             => @property.currency_type
      )
      redirect_to gateway.redirect_url_for(setup_response.token)
  end

  def error
  end

  def payment_transfer
      if  !params[:application].nil?
          @application = Application.find(params[:application][:id])
	   if ( !params[:payment_token].blank? ) and ( params[:payment_token] == @application.payment_token)
	      property = Property.find(@application.property_id)
              if  property.token_received_notification
                  @application.movein!
		  @application.save(false)
                  flash[:notice]  = "Token Received Successfully"
#               redirect_to payment_transfer_notification_my_property_path(@application)
                  redirect_to my_dashboard_my_account_path
           else
                 @application.errors.add_to_base("Something went Wrong.")
	         render :partial=>"shared/receive_payment", :layout=>"new/application"
	      end
	  else
              if  params[:payment_token].blank?
                  @application.errors.add_to_base("Enter payment code.")
           else
                  @application.errors.add_to_base("Enter a valid payment code for receive payment.")
	      end
	      render :partial=>"shared/receive_payment", :layout=>"new/application"
	  end
    else
        redirect_to home_path
     end
  end


  private

  def gateway
    gateway ||= PaypalExpressGateway.new(
      :login => "pay_api1.boxyroom.com",
      :password => '54E5NKW6JJKDQ9CQ',
      :signature => 'AV3RMb5aIZeV9GFhUL9wzB8g5pD6AZXz67ZduFQ5RYff0KJNnPGIjEZv'
    )
    return gateway
  end

  def credit_card_gateway
    ActiveMerchant::Billing::Base.mode = :production if RAILS_ENV != "production"
    ActiveMerchant::Billing::PaypalGateway.default_currency = "USD"
    gateway ||= ActiveMerchant::Billing::PaypalGateway.new(
      :login => "pay_api1.boxyroom.com",
      :password => "54E5NKW6JJKDQ9CQ",
      :signature => "AV3RMb5aIZeV9GFhUL9wzB8g5pD6AZXz67ZduFQ5RYff0KJNnPGIjEZv"
    )
    return gateway
  end

  def card_info
    card = ActiveMerchant::Billing::CreditCard.new(
      :type               => params[:cardtype],
      :number             => params[:credit_card_information][:cardno],
      :verification_value => params[:credit_card_information][:ccv],
      :month              => params[:date][:month],
      :year               => params[:date][:year],
      :first_name         => params[:credit_card_information][:firstname],
      :last_name          => params[:credit_card_information][:lastname]
       )
     return card
  end

  def payment_token_generate
    alphanumerics = [('0'..'9'),('A'..'Z'),('a'..'z')].map {|range| range.to_a}.flatten
    payment_token = (0...6).map { alphanumerics[Kernel.rand(alphanumerics.size)] }.join
    return payment_token
  end

  def response_credit_card_payment(res,amount)
    if res.success?
        succ = gateway.capture(amount, res.authorization)
        if succ.success?
            return true
	end
    end
    return false
  end

  
end
