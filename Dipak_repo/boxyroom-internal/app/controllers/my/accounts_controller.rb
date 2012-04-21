class My::AccountsController < ApplicationController
  before_filter :require_user

  before_filter :redirect_to_my_dashboard, :only =>[:show]

  before_filter :update_currency_rate, :only =>[:my_dashboard]
  filter_access_to :all

  SEQUENCE_MESSAGE = ['first_name', 'last_name', 'user_payment_transfer_mail', 'avatar_content_type', 'avatar_file_size' , 'password',  'password_confirmation']

  def more_applications
    @dash_board_applications = current_user.applications.approved
    render :partial => "dash_board_application", :collection => @dash_board_applications
  end

  def show
  end


   ## Temp action for dashboard
  def my_dashboard
   @messages_for_me = current_user.received_messages.messages_to_me 'unread'
   @dash_board_applications = current_user.applications.approved
   @applications = current_user.applications.new_applications_by_me 7.days.ago
   change_status_approved_apps
   change_status_approved_apps_for_me
   @selected_tab = "MyDashboard"
   render :layout=>"new/application"
  end


  # GET /my/account/edit
  # GET /my/account/edit.xml
  def edit
    render :layout=>"new/application"
  end

  def my_account
    @applications_for_me = applications_for_my_properties
    @selected_tab = "Account"
    render :layout=>"new/application"
  end

  # PUT /my/account
  # PUT /my/account.xml
  def update
    @user = @current_user #User.find(params[:id])
    if params[:user][:password].empty? and params[:user][:password_confirmation].empty?
        @user.change_password = false
    else
        @user.change_password = true
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
    	if  !(params[:user][:password].empty?)
	     @user.deliver_password_reset_instructions!
	    end
        flash[:notice] = 'Account updated!'
	    format.html { redirect_to edit_my_account_path}
        format.xml  { head :ok }
      else
	    sequence = error_messages_in_sequence(@user.errors, SEQUENCE_MESSAGE)
	    @user.errors.clear
	    sequence.each{|mess| @user.errors.add_to_base(mess)}
	    format.html { render :action => "edit" ,:layout=>"new/application" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def delete_user_pic
     current_user.avatar = nil
     if current_user.save
        flash[:notice] = "Picture deleted successfully"
        redirect_to :action => :edit, :layout=>"new/application" 
     end
  end


   def my_properties
    @properties = current_user.properties.paginate :page => params[:page],:per_page => 20
    @selected_tab = "Properties"
    render :layout => "new/application"
  end

  def my_profile
    @properties = current_user.properties
    @applications = current_user.applications
    @selected_tab = "profile"
    render :layout => "new/application"
  end

  def  photos_property
      @photo = Picture.new(params[:picture])
      if @photo.valid?
        @photo.save
	x = params[:page_refresh]
	if  x.to_i == 1
	    session[:pictures_id] = nil
	    (session[:pictures_id] ||= []) << @photo.id
      else
	    (session[:pictures_id] ||= []) << @photo.id
	end
	str1 = String.new
	str1 = 'photo_div'+ x.to_s
	y = x.to_i+1
	responds_to_parent do
	  render :update do |page|
	  # this plugin work like this only will search on net to modify it
	  page << "var obj#{y}={'div_id':'#{str1}','photo_id':'#{@photo.id}'};document.getElementById('#{str1}').innerHTML ='<a href=JavaScript:void(0); onclick=delete_image(obj#{y});  class=delete_property_image></a><img width=148 height=132 src=#{@photo.image.url(:middle)} id=#{@photo.id}/>';document.getElementById('refresh').value =#{y};document.getElementById('picture_select').value = #{0} ;document.getElementById('upload_status').value = #{1} ;"
	  end
	end
      end
  end

  def delete_image
    @photo = Picture.find(params[:id])
    status = @photo.destroy
    if status
      session[:pictures_id].delete(params[:id].to_i)
      render :json => status.to_json
   else
      render :json => status.to_json
    end
  end

  def delete_previous_image
    @photo = Picture.find(params[:id])
    status = @photo.destroy
    if status
      render :json => status.to_json
    else
      render :json => status.to_json
    end
  end

  def  upload_property_docs
      @propertydoc = PropertyDoc.new(params[:property_doc])
      if @propertydoc.valid?
        @propertydoc.save
	    x = params[:page_refresh]
	    if  x.to_i == 1
	      session[:prop_doc_id] = nil
	      (session[:prop_doc_id] ||= []) << @propertydoc.id
        else
	      (session[:prop_doc_id] ||= []) << @propertydoc.id
	    end
	    str1 = String.new
	    str1 = 'doc_photo_div'+ x.to_s
	    y = x.to_i+1
	    responds_to_parent do
	      render :update do |page|
	      # this plugin work like this only will search on net to modify it
	        page << "var obj#{y}={'div_id':'#{str1}','photo_id':'#{@propertydoc.id}'};document.getElementById('#{str1}').innerHTML ='<a href=JavaScript:void(0); onclick=delete_prop_doc(obj#{y});  class=delete_property_image></a><img width=148 height=132 src=#{@propertydoc.document.url(:middle)} id=#{@propertydoc.id}/>';document.getElementById('refresh_doc').value =#{y};document.getElementById('doc_select').value = #{0} ;document.getElementById('upload_doc_status').value = #{1} ;"
	      end  
	   end
      end
  end

  def delete_prop_doc
    @propertydoc = PropertyDoc.find(params[:id])
    status = @propertydoc.destroy
    if status
      session[:prop_doc_id].delete(params[:id].to_i)
      render :json => status.to_json
   else
      render :json => status.to_json
    end
  end

  def delete_previous_doc
    @propertydoc = PropertyDoc.find(params[:id])
    status = @propertydoc.destroy
    if status
      render :json => status.to_json
    else
      render :json => status.to_json
    end
  end



 private

 def redirect_to_my_dashboard
  redirect_to :my_dashboard_my_account
 end

 def update_currency_rate
#  Need to make a crone job
   ExchangeRate.delete_all
   CurrencyExchange.currency_exchange(1,"USD","SGD")
 end

 def change_status_approved_apps
  current_user.applications.approved.each do |app| 
   app.cancel! if date_approve_hours_count(app.approved_at)
  end
 end

 def change_status_approved_apps_for_me
  @applications_for_me = latest_applications_for_my_properties
  if !(@applications_for_me.nil?)
   @applications_for_me.each do |app|
    if !(app[0].nil?)
      app[0].cancel! if app[0].approved? and date_approve_hours_count(app[0].approved_at)
    end
   end
  end
 end

end
