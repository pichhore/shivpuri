class Admin::AlertDefinitionsController < Admin::AdminController
  # GET /alert_definitions
  # GET /alert_definitions.xml
  def index
    @alert_definitions = AlertDefinition.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @alert_definitions }
    end
  end

  # GET /alert_definitions/1
  # GET /alert_definitions/1.xml
  def show
    @alert_definition = AlertDefinition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alert_definition }
    end
  end

  # GET /alert_definitions/new
  # GET /alert_definitions/new.xml
  def new
    @alert_definition = AlertDefinition.new
    @alert_trigger_types = AlertTriggerType.find(:all)
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alert_definition }
    end
  end

  # GET /alert_definitions/1/edit
  def edit
    @alert_definition = AlertDefinition.find(params[:id])
    @alert_trigger_types = AlertTriggerType.find(:all)
  end

  # POST /alert_definitions
  # POST /alert_definitions.xml
  def create
    @alert_definition = AlertDefinition.new(params[:alert_definition])
    @alert_trigger_types = AlertTriggerType.find(:all)
    
    respond_to do |format|
      if @alert_definition.save
        flash[:notice] = 'AlertDefinition was successfully created.'
        format.html { redirect_to(admin_alert_definition_path(@alert_definition)) }
        format.xml  { render :xml => @alert_definition, :status => :created, :location => @alert_definition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alert_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alert_definitions/1
  # PUT /alert_definitions/1.xml
  def update
    @alert_definition = AlertDefinition.find(params[:id])
    @alert_trigger_types = AlertTriggerType.find(:all)
    respond_to do |format|
      if @alert_definition.update_attributes(params[:alert_definition])
        flash[:notice] = 'AlertDefinition was successfully updated.'
        format.html { redirect_to(admin_alert_definition_path(@alert_definition)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alert_definition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alert_definitions/1
  # DELETE /alert_definitions/1.xml
  def destroy
    @alert_definition = AlertDefinition.find(params[:id])
    @alert_definition.destroy

    respond_to do |format|
      format.html { redirect_to(admin_alert_definitions_path) }
      format.xml  { head :ok }
    end
  end
end
