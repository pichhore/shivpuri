class  Admin::BadgesController < Admin::AdminController
  uses_yui_editor
  
  active_scaffold :badge

  # GET /badges
  # GET /badges.xml
  def index
    @badges = Badge.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @badges }
    end
  end

  # GET /badges/1
  # GET /badges/1.xml
  def show
    @badge = Badge.find(params[:id])
    @user_badge = @badge.badge_image
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @badge }
    end
  end

  # GET /badges/new
  # GET /badges/new.xml
  def new
    @badge = Badge.new
    @badge_image = BadgeImage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @badge }
    end
  end

  # GET /badges/1/edit
  def edit
    @badge = Badge.find(params[:id])
    @user_badge = BadgeImage.find_by_badge_id(params[:id])
  end

  # POST /badges
  # POST /badges.xml
  def create
    @badge = Badge.new(params[:badge])
    
    respond_to do |format|
      if @badge.valid?
        #unless params[:badge_image][:uploaded_data].blank?
        Badge.transaction do
          if @badge.save
            unless params[:badge_image].nil? || params[:badge_image][:uploaded_data].blank?
              return if upload_badge_image(false)
            end
          end
        end
        #end
        flash[:notice] = 'Badge was successfully created.'
        format.html { redirect_to(admin_badge_path(@badge)) }
        format.xml  { render :xml => @badge, :status => :created, :location => @badge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @badge.errors, :status => :unprocessable_entity }
      end
      
    end
  rescue ActiveRecord::Rollback
    redirect_to :controller => "admin/badges", :action => 'new'
  rescue Exception => e
    puts e.message
    redirect_to :controller => "admin/badges", :action => 'new'
  end

  # PUT /badges/1
  # PUT /badges/1.xml
  def update
    @badge = Badge.find(params[:id])
    @badge_image = BadgeImage.find_by_badge_id(params[:id])
    respond_to do |format|
      if @badge.update_attributes(params[:badge])
        unless params[:badge_image].nil? || params[:badge_image][:uploaded_data].blank?
          return if upload_badge_image(false)
        end
        flash[:notice] = 'Badge was successfully updated.'
        format.html { redirect_to(admin_badge_path(@badge)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @badge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /badges/1
  # DELETE /badges/1.xml
  def destroy
    @badge = Badge.find(params[:id])
    @badge.destroy

    respond_to do |format|
      format.html { redirect_to(admin_badges_path) }
      format.xml  { head :ok }
    end
  end

  def upload_badge_image(retrun_flag = true)
    @badge_image = BadgeImage.new(params[:badge_image])
    @badge_image.badge_id = @badge.id
      if @badge_image.valid?
        badge_image = BadgeImage.find(:all, :conditions=>[" badge_id = ? ",@badge.id])
        if badge_image.size > 0
          old_badge_image = BadgeImage.find(badge_image[0].id)
          old_badge_image.destroy
        end
        @badge_image.save!
        return retrun_flag
      else
        @badge_image = BadgeImage.find(:first, :conditions=>[" badge_id = ? ",@badge.id])
        return false
      end
  end

  def show_users_wrt_badges
    @badge = Badge.find_by_id(params[:id])
    @users_badges = @badge.users unless @badge.blank?
  end
end
