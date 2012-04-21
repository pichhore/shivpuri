class AccountMarketingController < ApplicationController

  before_filter :login_required, :only=>["welcome_email", "daily_email", "weekly_email", "trust_responder_email", "update_buyer_responder_notification", "return_to_previous_page", "trust_responder_email_series", "update_trust_responder_notification", "wholesale_welcome_email", "wholesale_daily_email", "wholesale_weekly_email"]
  uses_yui_editor(:only => ["welcome_email", "daily_email", "weekly_email", "update_buyer_responder_notification",  "trust_responder_email_series", "update_trust_responder_notification", "wholesale_welcome_email", "wholesale_daily_email", "wholesale_weekly_email"])

  before_filter :only=>["welcome_email", "daily_email", "weekly_email", "trust_responder_email", "update_buyer_responder_notification", "return_to_previous_page", "trust_responder_email_series", "update_trust_responder_notification", "wholesale_welcome_email", "wholesale_daily_email", "wholesale_weekly_email"] do  |controller|  
    controller.send(:check_investor_role,[BASIC_USER_CLASS[:uc1_type],BASIC_USER_CLASS[:uc2_type]])
  end

  def wholesale_welcome_email
    get_buyer_responder_email BuyerNotification::SUMMARY_TYPE['wholesale_welcome']
  end

  def wholesale_daily_email
    get_buyer_responder_email BuyerNotification::SUMMARY_TYPE['wholesale_daily']
  end

  def wholesale_weekly_email
    get_buyer_responder_email BuyerNotification::SUMMARY_TYPE['wholesale_weekly']
  end

  def welcome_email
    get_buyer_responder_email BuyerNotification::SUMMARY_TYPE['welcome']
  end

  def daily_email
    get_buyer_responder_email BuyerNotification::SUMMARY_TYPE['daily']
  end

  def weekly_email
    get_buyer_responder_email BuyerNotification::SUMMARY_TYPE['weekly']
  end

  def trust_responder_email
    get_buyer_responder_email BuyerNotification::SUMMARY_TYPE['trust_resp_series']
  end

  def update_buyer_responder_notification
    render :file => "#{RAILS_ROOT}/public/404.html" and return false if params[:buyer_notification].nil?
    case params[:commit]
      when "Preview"
        render :partial => "preview", :layout => true and return
    else
      begin
        update_buyer_notification_email
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error trying to update your settings. Please try again later or contact support",exp) and return
      end
    end
  end

  def return_to_previous_page
    summary_type = params[:summary_type] unless params[:summary_type].blank?
    summary_type = params[:buyer_notification][:summary_type] if !params[:buyer_notification].blank? and !params[:buyer_notification][:summary_type].blank?

    render :file => "#{RAILS_ROOT}/public/404.html" and return false if summary_type.nil?
    begin
      redirect_to :action => "welcome_email" and return if summary_type == BuyerNotification::SUMMARY_TYPE['welcome']
      redirect_to :action => "daily_email" and return if summary_type == BuyerNotification::SUMMARY_TYPE['daily']
      redirect_to :action => "weekly_email" and return if summary_type == BuyerNotification::SUMMARY_TYPE['weekly']
      redirect_to :action => "trust_responder_email" and return if summary_type == BuyerNotification::SUMMARY_TYPE['trust_resp_series']
      redirect_to :action => "wholesale_welcome_email" and return if summary_type == BuyerNotification::SUMMARY_TYPE['wholesale_welcome']
      redirect_to :action => "wholesale_daily_email" and return if summary_type == BuyerNotification::SUMMARY_TYPE['wholesale_daily']
      redirect_to :action => "wholesale_weekly_email" and return if summary_type == BuyerNotification::SUMMARY_TYPE['wholesale_weekly']
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      handle_error("Error trying to redirect. Please try again later or contact support",exp) and return
    end
  end

  def trust_responder_email_series
    @page_heading = "Buyer Trust Responder Series(Email#{params[:email_number].to_s})"
    get_buyer_responder_email 'trust_resp_series'
    get_trust_responder_email "trust_responder_email" + params[:email_number].to_s
  end

  def update_trust_responder_notification
    render :file => "#{RAILS_ROOT}/public/404.html" and return false if params[:buyer_notification].nil? && params[:trust_responder_notification].nil?
    case params[:commit]
      when "Preview"
      render :partial => "preview_trust_responder", :layout => true and return
    else
      begin
        update_trust_responder_email
      rescue  Exception => exp
        ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
        handle_error("Error trying to update your settings. Please try again later or contact support",exp) and return
      end
    end
  end

  private

  def get_buyer_responder_email (type)
    @summary_type = type
    @user_company_image = UserCompanyImage.find_by_user_id(current_user.id)
    @buyer_notification = BuyerNotification.get_buyer_notification(current_user.id , @summary_type) 
  end

  def get_trust_responder_email (type)
    @trust_responder_summary_type = type
    @trust_responder_notification = TrustResponderMailSeries.get_trust_responder_notification(@buyer_notification,@trust_responder_summary_type)
  end

  def update_buyer_notification_email
    return unless request.post?
    save_or_update_buyer_notification
    flash[:notice] = "Notification settings has been updated successfully."
    return_to_previous_page
  end

  def update_trust_responder_email
    return unless request.post?
    save_or_update_buyer_notification
    save_or_update_trust_responder_notification
    flash[:notice] = "Notification settings has been updated successfully."
    redirect_to :action => "trust_responder_email_series", :email_number => params[:email_number]
  end

  def save_or_update_buyer_notification
    @buyer_notification = BuyerNotification.find(:first,:conditions => ["user_id = ? and summary_type LIKE ?",current_user.id,params[:buyer_notification][:summary_type]])
    if @buyer_notification.nil?
      @buyer_notification = BuyerNotification.new(params[:buyer_notification])
      @buyer_notification.user_id = current_user.id
      @buyer_notification.save
    else
      @buyer_notification.update_attributes(params[:buyer_notification])
    end
  end

  def save_or_update_trust_responder_notification
    @trust_responder_notification = @buyer_notification.trust_responder_mail_series.find(:first, :conditions => ["trust_responder_summary_type=?", params[:trust_responder_notification][:trust_responder_summary_type]])
    if @trust_responder_notification.blank?
      @trust_responder_notification = @buyer_notification.trust_responder_mail_series.create(params[:trust_responder_notification])
    else
      @trust_responder_notification.update_attributes(params[:trust_responder_notification])
    end
  end
end