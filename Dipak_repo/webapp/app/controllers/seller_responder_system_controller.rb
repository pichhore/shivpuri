class SellerResponderSystemController < ApplicationController
  uses_yui_editor

  before_filter :login_required

  before_filter do  |controller|
    controller.send(:check_investor_role,[BASIC_USER_CLASS[:uc2_type]])
  end

  #sequence_one = New Lead
  def sequence_one
  end

  #sequence_two = Trying To Reach You
  def sequence_two
  end

  #sequence_three = After Call: Next Steps
  def sequence_three
  end

  #sequence_four = After Call: Not Now
  def sequence_four
  end

  #sequence_five = Do Not Call
  def sequence_five
  end

  def seller_responder_sequence_series
    render :file => "#{RAILS_ROOT}/public/404.html" and return false if params[:sequence_name].blank? or params[:email_number].blank?
    @sequence_name, @email_number = SellerResponderSequence::SEQUENCE_NAME[params[:sequence_name]], params[:sequence_name] == "sequence_one" ? "Thank You" : "Email#{params[:email_number].to_s}"
    @seller_notification = SellerResponderSequence.get_seller_responder(current_user.id,params[:sequence_name])
    @seller_responder_notification = SellerResponderSequenceMapping.get_seller_responder_sequence_notification(@seller_notification,params[:email_number],params[:sequence_name])
  end

  def update_seller_responder_notification
    render :file => "#{RAILS_ROOT}/public/404.html" and return false if params[:seller_notification].nil? && params[:seller_responder_notification].nil?
    case params[:commit]
      when "Preview"
      render :partial => "preview", :layout => true and return
    else
      update_seller_responder_sequence_notification
    end
  end

private

  def update_seller_responder_sequence_notification
    begin
      find_or_create_seller_responder_notification
      update_seller_responder_emails
      redirect_to :action=>'seller_responder_sequence_series', :email_number => @seller_responder_notification.email_number, :sequence_name => @seller_notification.sequence_name
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      handle_error("Error trying to redirect. Please try again later or contact support",exp) and return
    end
  end

  def find_or_create_seller_responder_notification
    @seller_notification = SellerResponderSequence.find(:first,:conditions => ["user_id = ? and sequence_name LIKE ?",current_user.id,params[:seller_notification][:sequence_name]])
    if @seller_notification.nil?
      @seller_notification = SellerResponderSequence.new(params[:seller_notification])
      @seller_notification.user_id = current_user.id
      @seller_notification.save
    end
  end

  def update_seller_responder_emails
    @seller_responder_notification = @seller_notification.seller_responder_sequence_mappings.find_by_email_number(params[:seller_responder_notification][:email_number])[0]
    if @seller_responder_notification.blank?
      @seller_responder_notification = @seller_notification.seller_responder_sequence_mappings.create(params[:seller_responder_notification])
    else
      @seller_responder_notification.update_attributes(params[:seller_responder_notification])
    end
  end
end