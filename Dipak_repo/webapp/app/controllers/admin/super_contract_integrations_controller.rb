# require 'pdfkit'
class Admin::SuperContractIntegrationsController < Admin::AdminController
  layout "admin"
  uses_yui_editor
  # GET /admin_super_contract_integrations
  # GET /admin_super_contract_integrations.xml
  def index
    @super_contract_integrations = SuperContractIntegration.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @super_contract_integrations }
    end
  end

  # GET /admin_super_contract_integrations/1
  # GET /admin_super_contract_integrations/1.xml
  def show
    @super_contract_integration = SuperContractIntegration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @super_contract_integration }
    end
  end

  # GET /admin_super_contract_integrations/new
  # GET /admin_super_contract_integrations/new.xml
  def new
    @super_contract_integration = SuperContractIntegration.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @super_contract_integration }
    end
  end

  # GET /admin_super_contract_integrations/1/edit
  def edit
    @super_contract_integration = SuperContractIntegration.find(params[:id])
  end

  # POST /admin_super_contract_integrations
  # POST /admin_super_contract_integrations.xml
  def create
    @super_contract_integration = SuperContractIntegration.new(params[:super_contract_integration])

    if @super_contract_integration.save
      flash[:notice] = 'Contract was successfully created.'
      redirect_to(admin_super_contract_integration_path(@super_contract_integration))
    else
      render :action => "new"
    end
  end

  # PUT /admin_super_contract_integrations/1
  # PUT /admin_super_contract_integrations/1.xml
  def update
    @super_contract_integration = SuperContractIntegration.find(params[:id])

    if @super_contract_integration.update_attributes(params[:super_contract_integration])
      flash[:notice] = 'Contract was successfully updated.'
      redirect_to(admin_super_contract_integration_path(@super_contract_integration))
    else
      render :action => "edit" 
    end
  end

  # DELETE /admin_super_contract_integrations/1
  # DELETE /admin_super_contract_integrations/1.xml
  def destroy
    @super_contract_integration = SuperContractIntegration.find(params[:id])
    @super_contract_integration.destroy

    respond_to do |format|
      format.html { redirect_to(admin_super_contract_integrations_url) }
      format.xml  { head :ok }
    end
  end

  def print_contract
    @super_contract_integration = SuperContractIntegration.find(params[:id])
    unless @super_contract_integration.blank?
      contract_name = "#{@super_contract_integration.state.name}-Contract.pdf"
      html_content = render_to_string(:action => 'print_contract', :layout => false)
      pdf_convert = PDFKit.new(html_content, :margin_right => '0.10in',:margin_left => '0.10in',:margin_top => '0.20in')
      send_data(pdf_convert.to_pdf,:filename=>contract_name)
    end
  end  


end
