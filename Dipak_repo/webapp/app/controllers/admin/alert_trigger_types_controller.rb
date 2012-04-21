class Admin::AlertTriggerTypesController < Admin::AdminController
  # GET /alert_trigger_types
  # GET /alert_trigger_types.xml
  def index
    @alert_trigger_types = AlertTriggerType.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @alert_trigger_types }
    end
  end

  # GET /alert_trigger_types/1
  # GET /alert_trigger_types/1.xml
  def show
    @alert_trigger_type = AlertTriggerType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alert_trigger_type }
    end
  end

  # GET /alert_trigger_types/new
  # GET /alert_trigger_types/new.xml
  def new
    @alert_trigger_type = AlertTriggerType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alert_trigger_type }
    end
  end

  # GET /alert_trigger_types/1/edit
  def edit
    @alert_trigger_type = AlertTriggerType.find(params[:id])
  end

  # POST /alert_trigger_types
  # POST /alert_trigger_types.xml
  def create
    @alert_trigger_type = AlertTriggerType.new(params[:alert_trigger_type])

    respond_to do |format|
      if @alert_trigger_type.save
        flash[:notice] = 'AlertTriggerType was successfully created.'
        format.html { redirect_to(admin_alert_trigger_type_path(@alert_trigger_type)) }
        format.xml  { render :xml => @alert_trigger_type, :status => :created, :location => @alert_trigger_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alert_trigger_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alert_trigger_types/1
  # PUT /alert_trigger_types/1.xml
  def update
    @alert_trigger_type = AlertTriggerType.find(params[:id])

    respond_to do |format|
      if @alert_trigger_type.update_attributes(params[:alert_trigger_type])
        flash[:notice] = 'AlertTriggerType was successfully updated.'
        format.html { redirect_to(admin_alert_trigger_type_path(@alert_trigger_type)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alert_trigger_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alert_trigger_types/1
  # DELETE /alert_trigger_types/1.xml
  def destroy
    @alert_trigger_type = AlertTriggerType.find(params[:id])
    @alert_trigger_type.destroy

    respond_to do |format|
      format.html { redirect_to(admin_alert_trigger_types_path) }
      format.xml  { head :ok }
    end
  end
end
