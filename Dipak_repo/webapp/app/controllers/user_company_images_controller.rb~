class UserCompanyImagesController < ApplicationController
  before_filter :login_required

  layout "application"
  # GET /buyer_user_images
  # GET /buyer_user_images.xml
  def index
    render :text=>"update not supported", :status=>500
  end

  # GET /buyer_user_images/1
  # GET /buyer_user_images/1.xml
  def show
    render :text=>"update not supported", :status=>500
  end

  # GET /buyer_user_images/new
  # GET /buyer_user_images/new.xml
  def new
    @user_company_image = UserCompanyImage.new
  end

  # GET /buyer_user_images/1/edit
  def edit
    render :text=>"update not supported", :status=>500
  end

  # POST /buyer_user_images
  # POST /buyer_user_images.xml

  def create
    render :text=>"update not supported", :status=>500
  end

  # PUT /user_company_images/1
  # PUT /user_company_images/1.xml
  def update
    render :text=>"update not supported", :status=>500
  end

  # DELETE /user_company_images/1
  # DELETE /user_company_images/1.xml
  def destroy
    id = params[:id]
    if !id or id.empty?
      handle_error("Must provide a company_image_id to destroy") and return
    end

    @user_company_image = UserCompanyImage.find_by_id(id)
    if !@user_company_image
      handle_error("Must provide a valid company_image_id to destroy") and return
    end

    @user_company_image.destroy
     flash[:notice] = 'Company Image deleted successfully .'
     render :partial=>"user_company_images/image_upload" and return
  rescue  Exception => e
    ExceptionNotifier.deliver_exception_notification( e,self, request, params)
    handle_error("Error while trying to delete the profile image",e)
  end
end
