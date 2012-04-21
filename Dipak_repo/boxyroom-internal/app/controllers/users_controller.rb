class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:edit, :update]

  filter_resource_access

  def new
    @user = User.new
    render :layout => "new/login"
  end

  def create
    @user = User.new(params[:user])
    @user.change_password = true
    if @user.save_without_session_maintenance
      flash[:notice] = "Account registered! Please check your e-mail for your account activation code."
      redirect_to root_url
    else
      sequence = Array.[]('first_name', 'last_name', 'email', 'password',  'password_confirmation','terms_and_policy')    
      sequence = error_messages_in_sequence(@user.errors, sequence)
      @user.errors.clear
      sequence.each do |mess|
	@user.errors.add_to_base(mess)
      end
      render :action => :new, :layout => "new/login"
    end
  end

  def show
    @user = User.find(params[:id])
  end


  
end
