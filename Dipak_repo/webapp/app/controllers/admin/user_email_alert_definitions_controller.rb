class Admin::UserEmailAlertDefinitionsController < Admin::AdminController
  uses_yui_editor


  def index
    @email_alert_definitions = UserEmailAlertDefinition.find(:all)
  end


  def show
    @user_email_alert_definition = UserEmailAlertDefinition.find(params[:id])
  end


  def new
    @user_email_alert_definition = UserEmailAlertDefinition.new
  end


  def edit
    @user_email_alert_definition = UserEmailAlertDefinition.find(params[:id])
  end


  def create
    @user_email_alert_definition = UserEmailAlertDefinition.new(params[:user_email_alert_definition])
    if @user_email_alert_definition.save
      flash[:notice] = 'User Alert Definition was successfully created.'
      redirect_to(admin_user_email_alert_definition_path(@user_email_alert_definition)) 
    else
      render :action => "new" 
    end
  end


  def update
    @user_email_alert_definition = UserEmailAlertDefinition.find(params[:id])
    if @user_email_alert_definition.update_attributes(params[:user_email_alert_definition])
      flash[:notice] = 'User Email Alert Definition was successfully updated.'
      redirect_to(admin_user_email_alert_definition_path(@user_email_alert_definition)) 
    else
      render :action => "edit" 
    end
  end


  def destroy
    @user_email_alert_definition = UserEmailAlertDefinition.find(params[:id])
    @user_email_alert_definition.destroy
    redirect_to(admin_user_email_alert_definitions_path)
  end
end
