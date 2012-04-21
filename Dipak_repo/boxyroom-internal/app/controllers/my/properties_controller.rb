class My::PropertiesController < ApplicationController
  before_filter :require_user
  before_filter :check_payment_status, :only =>[ :receive_payment]
  before_filter :check_edit_authority, :only =>[ :edit]
  filter_resource_access 
  before_filter :check_payment_status_after_payment_transfer, :only => [:payment_transfer_notification]

  SEQUENCE = ['address_state','address_city', 'address_street_name','address_unit_no', 'address_postal_code', 'title', 'description','rooms','floor_area','monthly_rental','available_at']

  def show
    @property = current_user.properties.find(params[:id])
    @cancelled = @property.applications.cancelled || {}
    render :layout => "new/application"
  end


  def new
    @property = current_user.properties.build
    @property.build_address
    @picture = Picture.new
    @propertydoc = PropertyDoc.new
    render :layout => "new/application"
  end

  def edit
#     @property.pictures.build
    render :layout => "new/application"
  end

  def create
   @property = current_user.properties.build(params[:property])
    if @property.save
      update_property_images
      update_property_doc
      flash[:notice] = "Thank you for your listing, an email will be sent to you once it has been approved by an admin."
      redirect_to my_dashboard_my_account_path
    else
      sequence_e = error_messages_in_sequence(@property.errors, SEQUENCE)
      @property.errors.clear
      sequence_e.each do |mess|
	    @property.errors.add_to_base(mess)
      end
      render :action => "new", :layout => "new/application"
    end
  end

  def update
    @property = current_user.properties.find(params[:id])
    @property.attributes = params[:property]
    if @property.save
      update_property_images
      update_property_doc
      # alert all applicants for this property
      flash[:notice] = "Your changes have been saved."
      redirect_to my_property_path(@property)
    else
      sequence_e = error_messages_in_sequence(@property.errors, SEQUENCE)
      @property.errors.clear
      sequence_e.each do |mess|
	    @property.errors.add_to_base(mess)
      end
      flash[:error] = "You've got some errors."
      render :action => "edit", :layout => "new/application"
    end
  end

  def destroy
    @property = current_user.properties.find(params[:id])

    if @property.delist!
      flash[:notice] = "Your property has been delisted!"
    else
      flash[:error] = "You can't delist this property."
    end

    redirect_back_or_default(my_properties_my_account_path)
  end

  def resubmit
    @property = current_user.properties.find(params[:id])

    if @property.resubmit!
      flash[:notice] = "Your property has been resubmitted for approval, thank you."
    else
      flash[:error] = "You can't resubmit this property."
    end

    redirect_back_or_default(my_dashboard_my_account_path)
  end

  def relist
    @property = current_user.properties.find(params[:id])

    if @property.relist!
      flash[:notice] = "Your property has been relisted."
    else
      flash[:error] = "You can't reslist this property."
    end

    redirect_back_or_default(my_properties_my_account_path)
  end

  def receive_payment
    render :layout=>"new/application"
  end
  
  def property_doc
   @property = current_user.properties.find(params[:id]) 
   @selected_tab = "Properties"
   render :layout => "new/application"
  end
    
   def create_property_doc
   redirect_to property_doc_my_property_path(@property) and return if  params[:document].blank?
    @property.property_docs_attributes = params[:document].inject([]) {|arr, doc| arr << { :document => doc } }
    @property.action_flag = true
    if @property.save
        redirect_to property_doc_my_property_path(@property)
    else
      sequence = Array.[]('property_docs_document_content_type')
      sequence_e = error_messages_in_sequence(@property.errors, sequence)
      @property.errors.clear
      sequence_e.each do |mess|
	@property.errors.add_to_base(mess)
      end
     @selected_tab = "Properties"
      render :action => "property_doc", :layout => "new/application"
    end
  end  

    
  def delete_property_doc
    doc = PropertyDoc.find(params[:doc_id])
    if current_user.properties.include?(doc.property)
      doc.destroy
      flash[:notice] = "Document deleted successfully"
      redirect_to property_doc_my_property_path(doc.property)
    end
    rescue
     flash[:notice] = "Document does not exist"
     redirect_to property_doc_my_property_path(doc.property)
  end  


  def picture_destroy
     picture = Picture.find(params[:pic_id])
     if current_user.properties.include?(picture.property)
      picture.destroy
      flash[:notice] = "Picture deleted successfully"
      redirect_to :action => "edit",:id => picture.property
    end
    rescue
      flash[:notice] = "Picture does not exist"
      render :action => "edit",:id => picture.property,:layout => "new/application" 
  end
  
    def  payment_transfer_notification
      properties = current_user.properties.paid #Property.find(:all, :conditions => ["user_id = ? and status=?", current_user.id, 'paid'])
      @applications_for_me = Array.new
      properties.each do |f|
	temp = Application.find(:all, :conditions => ["property_id = ? and status=?", f.id, 'paid'])
	if temp.size>1
	  temp.each do |t|
	    @applications_for_me<< t 
	  end
      elsif !(temp.size == 0) 
	  @applications_for_me<< temp
	end
     end
      render :layout=>"new/application"
    end

  private

  def update_property_images
    unless session[:pictures_id].nil?
	 session[:pictures_id].each do |id|
	  picture = Picture.find(id)
	  picture.update_attributes(:property_id => @property.id)
	 end	
    end
    session[:pictures_id] = nil
  end

  def update_property_doc
    unless session[:prop_doc_id].nil?
	 session[:prop_doc_id].each do |id|
	  propertydoc = PropertyDoc.find(id)
	  propertydoc.update_attributes(:property_id => @property.id)
	 end	
    end
    session[:prop_doc_id] = nil
  end


  def check_payment_status
    @application = Application.find(params[:application_id])
      if !@application.paid?
        flash[:notice] = "Payment is not made for the application."
        redirect_to my_dashboard_my_account_path and return
      end

      unless @application.payment_transfer_status.nil?
        flash[:notice] = "You have been paid before."
        redirect_to my_dashboard_my_account_path and return
      end
  end
 
  def check_edit_authority
    @property = current_user.properties.find(params[:id])
    if !@property.editable?
        flash[:notice] = "You can't edit the property details once it is paid."
        redirect_to my_dashboard_my_account_path and return
    end
  end

 def check_payment_status_after_payment_transfer
    @application = Application.find(params[:id])
    unless @application.property.paid?
      flash[:notice] = "Propert has not been occupied."
      redirect_to my_dashboard_my_account_path and return
    end
 end

end
