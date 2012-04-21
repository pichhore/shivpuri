class BuyerUserImagesController < ApplicationController
  before_filter :login_required

  layout "application"
  # GET /buyer_user_images
  # GET /buyer_user_images.xml
  def index
    begin
      if request.put?
        begin
          buyer_user_image = BuyerUserImage.find_by_user_id(current_user.id)
          old_buyer_user_image = BuyerUserImage.find(buyer_user_image.id)
          if !old_buyer_user_image.nil?		 
            old_buyer_user_image.destroy
            @buyer_user_image = BuyerUserImage.new(params[:buyer_user_image])
            @buyer_user_image.user_id = current_user.id
          else		
            @buyer_user_image = old_buyer_user_image
            @buyer_user_image.update_attributes(params[:buyer_user_image])
          end

          @buyer_user_image.save!
          flash[:notice] = "Image upload successfully."
          if params[:from] == "step1"
            redirect_to :action => 'step1', :controller => :account and return
          else
            redirect_to :action => 'profile_image', :controller => :account and return
          end
        rescue ActiveRecord::RecordInvalid => e
#            ExceptionNotifier.deliver_exception_notification( e,self, request, params)
          flash[:error] = "Invalid image format. Please check that the image is one of the support types and , it is under 3MB in size."
          if params[:from] == 'step1'
            redirect_to :action => 'step1', :controller=>:account and return
          else
            redirect_to :action => 'profile_image', :controller=>:account and return
          end
        end
      else
         if params[:from] == 'step1'
            redirect_to :action => 'step1', :controller=>:account and return
	else
            redirect_to :action => 'profile_image', :controller=>:account and return
	end
      end
    rescue  Exception => exp
      ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
      flash[:notice] = "Error during processing of the image you uploaded"
       if params[:from] == 'step1'
            redirect_to :action => 'step1', :controller=>:account and return
	else
            redirect_to :action => 'profile_image', :controller=>:account and return
	end
    end
  end

  # GET /buyer_user_images/1
  # GET /buyer_user_images/1.xml
  def show
    render :text=>"update not supported", :status=>500
  end

  # GET /buyer_user_images/new
  # GET /buyer_user_images/new.xml
  def new
    @buyer_user_image = BuyerUserImage.new
  end

  # GET /buyer_user_images/1/edit
  def edit
    render :text=>"update not supported", :status=>500
  end

  # POST /buyer_user_images
  # POST /buyer_user_images.xml
  def create
    @buyer_user_image = BuyerUserImage.new(params[:buyer_user_image])
    @buyer_user_image.user_id = current_user.id
    @buyer_user_image.save
    flash[:notice] = "Image upload successfully."
      if params[:from] == 'step1'
            redirect_to :action => 'step1', :controller=>:account and return
	else
            redirect_to :action => 'profile_image', :controller=>:account and return
	end
  rescue ActiveRecord::RecordInvalid => e
    #flash[:error] = "Invalid image format. Please check that the image is one of the support types and , it is under 100k in size.<br/>#{e}"
    flash[:error] = "Invalid image format. Please check that the image is one of the support types and , it is under 3MB in size."
     if params[:from] == 'step1'
            redirect_to :action => 'step1', :controller=>:account and return
	else
            redirect_to :action => 'profile_image', :controller=>:account and return
	end
  rescue  Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    handle_error("Error during processing of the image you uploaded",exp)
  end

  # PUT /buyer_user_images/1
  # PUT /buyer_user_images/1.xml
  def update
    render :text=>"update not supported", :status=>500
  end

  # DELETE /buyer_user_images/1
  # DELETE /buyer_user_images/1.xml
  def destroy
    id = params[:id]
    if !id or id.empty?
      handle_error("Must provide a buyer_profile_image_id to destroy") and return
    end

    @buyer_user_image = BuyerUserImage.find_by_id(id)
    if !@buyer_user_image
      handle_error("Must provide a valid buyer_profile_image_id to destroy") and return
    end

    @buyer_user_image.destroy
     flash[:notice] = 'Image deleted successfully .'
     redirect_to :action => 'profile_image', :controller=>:account and return
  rescue  Exception => exp
    ExceptionNotifier.deliver_exception_notification( exp,self, request, params)
    handle_error("Error while trying to delete the profile image",exp)
  end
end
