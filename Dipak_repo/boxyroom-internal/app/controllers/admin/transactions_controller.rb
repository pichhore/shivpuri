class Admin::TransactionsController < ApplicationController
  before_filter :require_user
  filter_access_to :all

  def index
    @applications = []

    params[:queue] ||= "closing"

    case params[:queue].downcase
    when "open"
      # paid | unfulfilled | not flagged | within 7 days of payment
      @applications = Application.find(:all , :conditions => ["(status = ? or status = ?) and updated_at > ?", 'paid', 'moved_in', 30.days.ago ])
      @applications = @applications.paginate :page => params[:page],:per_page =>50
      @selected_sub_tab = "open"
    when "refunds"
      # paid | unfulfilled | flagged |
      @applications = Application.paid.to_refund
      @applications = @applications.paginate :page => params[:page],:per_page =>50
      @selected_sub_tab = "refunds"
    else
      # paid | unfulfilled | not flagged | after 7 days of payment
      @applications =Application.find(:all , :conditions => ["(status = ? or status = ?) and updated_at <= ?", 'paid', 'moved_in', 30.days.ago ])
      @applications = @applications.paginate :page => params[:page],:per_page =>50
      @selected_sub_tab = "closing"
      params[:queue] = "closing"
    end
    render :layout => "new/application"
  end

  def show
    @application = Application.find(params[:id])
  end

  def close
    flash[:notice] = "Not implemented yet"

    redirect_to admin_transactions_path
  end

  def  widthraw_done
    property = Property.find(params[:property_id])
    if property.send_widthraw_notification
      flash[:notice] = "Payment transferred successfully."
      redirect_to admin_transactions_path
   else
      flash[:notice] = "Somthing went wrong."
      redirect_to admin_transactions_path
    end
  end

end
