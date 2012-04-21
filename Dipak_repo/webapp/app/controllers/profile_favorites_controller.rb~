class ProfileFavoritesController < ApplicationController
  before_filter :login_required
  before_filter :load_profile
  before_filter :check_profile_ownership

  layout "application"

  # GET /profile_favorites
  # GET /profile_favorites.xml
  def index
    @profile_favorites = ProfileFavorite.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @profile_favorites.to_xml }
    end
  end

  # GET /profile_favorites/1
  # GET /profile_favorites/1.xml
  def show
    @profile_favorite = ProfileFavorite.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @profile_favorite.to_xml }
    end
  end

  # GET /profile_favorites/new
  def new
    @profile_favorite = ProfileFavorite.new
  end

  # GET /profile_favorites/1;edit
  def edit
    @profile_favorite = ProfileFavorite.find(params[:id])
  end

  # POST /profile_favorites
  # POST /profile_favorites.xml
  def create
    @profile_favorite = ProfileFavorite.new(params[:profile_favorite])
    @profile_favorite.profile = @profile
    @profile_favorite.target_profile_id = params[:target_profile_id] if params[:target_profile_id]
    @profile_favorite.is_near = params[:is_near] if params[:is_near]
    favorite_already_exists = ProfileFavorite.find_by_profile_id_and_target_profile_id(@profile.id, @profile_favorite.target_profile_id)

    if favorite_already_exists or @profile_favorite.valid?
      begin
        @profile_favorite.save! unless favorite_already_exists
        respond_to do |format|
          flash.now[:notice] = 'This profile is now in your list of favorites.'
          format.html { render :partial=>'create_success' and return if request.xhr? }
          format.xml  { head :created, :location => profile_profile_favorite_url(@profile_favorite) }
        end
      rescue Exception=> e
         ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        handle_error("Error adding the profile to your favorites.",e) and return
      end
    end

    render :partial=>"create_error"
  end

  # PUT /profile_favorites/1
  # PUT /profile_favorites/1.xml
  def update
    @profile_favorite = ProfileFavorite.find(params[:id])

    respond_to do |format|
      if @profile_favorite.update_attributes(params[:profile_favorite])
        flash[:notice] = 'ProfileFavorite was successfully updated.'
        format.html { redirect_to profile_profile_favorite_url(@profile_favorite) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile_favorite.errors.to_xml }
      end
    end
  end

  # DELETE /profile_favorites/1
  # DELETE /profile_favorites/1.xml
  def destroy
    begin
      @profile_favorite = ProfileFavorite.find(params[:id]) rescue ProfileFavorite.find_by_profile_id_and_target_profile_id(@profile.id, params[:id])
      # Verify that this favorite belongs to @profile
      if @profile_favorite.profile_id != @profile.id
        handle_error("You are not the proper owner of this favorite.") and return
      end

      @profile_favorite.destroy
      respond_to do |format|
        format.html { render :partial=>"destroy_success" and return if request.xhr? }
        format.xml  { head :ok }
      end
    rescue Exception => e
      ExceptionNotifier.deliver_exception_notification( e,self, request, params)
      handle_error("Error adding the profile to your favorites.",e) and return
    end
    render :partial=>"destroy_error"
  end
end
