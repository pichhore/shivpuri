class UserSessionsController < ApplicationController
  before_filter :require_no_user, :only => :new
  before_filter :require_user, :only => :destroy
  layout "new/login"

  def new
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save
      if request.session[:return_to].nil?
        flash[:notice] = "Login successful!"
        redirect_to my_dashboard_my_account_path
     else
        redirect_to request.session[:return_to]
	request.session[:return_to] = nil
      end
    else
      if @user_session.errors[:base] == ["You did not provide any details for authentication."]
        @user_session.errors.clear
	@user_session.errors.add_to_base("Enter your Email and Password")
      end
      flash[:error] = "Login unsuccessful!"
      render :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to root_path
  end
end

