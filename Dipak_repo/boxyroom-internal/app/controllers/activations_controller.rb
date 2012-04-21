class ActivationsController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]

  def new
    @user = User.find_using_perishable_token(params[:code], 1.week)
    if !@user.nil?
      if @user.active?
	flash[:notice] = "Your account is already active"
	redirect_to my_dashboard_my_account_path
	return
     else
        @user.activate!
	if @user_session =  UserSession.create(@user, true)
          flash[:notice] = "you have successfully activated"
          redirect_to my_dashboard_my_account_path
        end 
      end
   else
        flash[:notice] = "Account can not be activated."
        redirect_to root_path
    end
  end

  def create
    @user = User.find_using_perishable_token(params[:code], 1.week) || (raise Exception)

    if @user.active?
      flash[:notice] = "Your account is already active"
      redirect_to my_dashboard_my_account_path
      return
    end

    if @user.activate!
      flash[:notice] = "Account successfully Activated!"
      redirect_to login_path
    else
      render :action => :new
    end

  end

end
