class Admin::UsersController < ApplicationController
  before_filter :require_user
  filter_resource_access
  before_filter :not_current_user, :only => [:role_user, :role_admin]
  before_filter :check_current, :only => [:reinstate, :suspend]
  def index
    @users = User.all(:include=>[:properties,:applications]).sort_by{|p| p.first_name.downcase}

    #Sort By name
#     @users = User.find(:all).sort_by{|p| p.first_name.downcase}

    #Sort By email
#     @users = User.find(:all).sort_by{|p| p.email.downcase}

    render :layout=>"new/application"
  end

  def show
    @user = User.find(params[:id])
    @properties = @user.properties
    @applications = @user.applications
    render :layout=>"new/application"
  end

  def reinstate
    if @user.toggle! :suspended
      flash[:notice] = "#{@user.full_name} has been reinstated."
    else
      flash[:notice] = "Could not reinstate #{@user.full_name}."
    end

    redirect_to admin_users_path
  end

  def suspend
    if @user.toggle! :suspended
      flash[:notice] = "#{@user.full_name} has been suspended."
    else
      flash[:notice] = "Could not suspend #{@user.full_name}."
    end

    redirect_to admin_users_path
  end

  def role_admin
    if @user.roles[0].role_admin!
      flash[:notice] = "#{@user.full_name} has been granted admin access."
    else
      flash[:notice] = "#{@user.full_name} Could not be granted admin access."
    end

    redirect_to admin_users_path
  end


  def role_user
    if @user.roles[0].role_user!
      flash[:notice] = "#{@user.full_name} is simple user now."
    else
      flash[:notice] = "#{@user.full_name} Could not be converted into simple user."
    end

    redirect_to admin_users_path
  end

  private

  def not_current_user
    check_user_status
    if @user == current_user
      flash[:notice] = "You cannot perform administrative functions on your own account."
      redirect_to admin_users_path and return
    end
  end

  def check_current
    if @user == current_user
      flash[:notice] = "You cannot perform administrative functions on your own account."
      redirect_to admin_users_path and return
    end
  end

  def check_user_status
   @user = User.find(params[:id])
   redirect_to home_path and return if (@user.suspended? and !@user.active)
  end

end
