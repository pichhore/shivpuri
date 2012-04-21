class Admin::PropertiesController < ApplicationController
  before_filter :require_user
  filter_resource_access
  LISTING_PENDING="listing-pending"
  PENDING_VERIFICATION="pending-verification"
  APPROVED_LISTING="approved-listing"
  
  def index
    params[:queue] ||= LISTING_PENDING
    case params[:queue]
      when LISTING_PENDING
        @properties = Property.pending_approval
      when PENDING_VERIFICATION
        @properties = Property.pending_document_verification
      when APPROVED_LISTING
        @properties = Property.approved_listing
               
    end
    @properties = @properties.paginate :page => params[:page],:per_page =>50 
    @selected_sub_tab_property = params[:queue]
    render  :layout => 'new/application'
  end

  def approve
    if @property.approve!
      flash[:notice] = "Property has been approved for listing!"
    else
      flash[:error] = "You can't approve this listing."
    end

    redirect_to admin_properties_path
  end

  def reject
    if @property.reject!
      @user = User.find_by_id(@property.user_id)
      @address = Address.find_address(@property.id)
      @country = @address.country
      Notifier.deliver_reject_property_documents(@user,@address,@country)
      flash[:notice] = "Property has been rejected."
    else
      flash[:error] = "You can't reject this listing."
    end

    redirect_to admin_properties_path
  end

  def refund
    if @property.paid_application.refund!
      flash[:notice] = "Application has been refunded."
    else
      flash[:error] = "You can't reject this application."
    end

    redirect_to admin_properties_path
  end
  
   def property_verification
    @property.update_attribute(:verified ,"verified")
     flash[:notice] = "Property has been verified"
    redirect_to property_path
  end
  
end
