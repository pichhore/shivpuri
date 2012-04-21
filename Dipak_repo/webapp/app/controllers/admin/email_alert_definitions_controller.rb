class Admin::EmailAlertDefinitionsController < Admin::AdminController
  uses_yui_editor
  # GET /alert_definitions
  # GET /alert_definitions.xml
  def index
    @email_alert_definitions = EmailAlertDefinition.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @email_alert_definitions }
    end
  end

  # GET /alert_definitions/1
  # GET /alert_definitions/1.xml
  def show
    @email_alert_definition = EmailAlertDefinition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email_alert_definition }
    end
  end

  # GET /alert_definitions/new
  # GET /alert_definitions/new.xml
  def new
    @email_alert_definition = EmailAlertDefinition.new
    @alert_trigger_types = AlertTriggerType.find(:all, :conditions => ["method_name in('admin_only','on_event')"])
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_alert_definition }
    end
  end

  # GET /alert_definitions/1/edit
  def edit
    @email_alert_definition = EmailAlertDefinition.find(params[:id])
    @alert_trigger_types = AlertTriggerType.find(:all, :conditions => ["method_name in('admin_only','on_event')"])
  end

  # POST /alert_definitions
  # POST /alert_definitions.xml
  def create
    @email_alert_definition = EmailAlertDefinition.new(params[:email_alert_definition])
    @alert_trigger_types = AlertTriggerType.find(:all)
    
    respond_to do |format|
      if @email_alert_definition.save
        flash[:notice] = 'AlertDefinition was successfully created.'
        format.html { redirect_to(admin_email_alert_definition_path(@email_alert_definition)) }
        format.xml  { render :xml => @email_alert_definition, :status => :created, :location => @email_alert_definition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email_alert_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alert_definitions/1
  # PUT /alert_definitions/1.xml
  def update
    @email_alert_definition = EmailAlertDefinition.find(params[:id])
    @alert_trigger_types = AlertTriggerType.find(:all)
    respond_to do |format|
      if @email_alert_definition.update_attributes(params[:email_alert_definition])
        flash[:notice] = 'Email AlertDefinition was successfully updated.'
        format.html { redirect_to(admin_email_alert_definition_path(@email_alert_definition)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email_alert_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alert_definitions/1
  # DELETE /alert_definitions/1.xml
  def destroy
    @email_alert_definition = EmailAlertDefinition.find(params[:id])
    @email_alert_definition.destroy

    respond_to do |format|
      format.html { redirect_to(admin_email_alert_definitions_path) }
      format.xml  { head :ok }
    end
  end
end
