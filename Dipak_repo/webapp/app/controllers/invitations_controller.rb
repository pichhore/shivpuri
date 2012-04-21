class InvitationsController < ApplicationController
  layout "application"

  before_filter :login_required, :except=>[:show]

  # GET /invitations
  # GET /invitations.xml
  def index
    @invitations = Invitation.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @invitations.to_xml }
    end
  end

  # GET /invitations/1
  # GET /invitations/1.xml
  def show
    @invitation = Invitation.find(params[:id])
    @invitation.update_attributes(:accepted_at=>Time.now) if @invitation.accepted_at.nil?

    # For now, just redirect to the homepage after marking the invitation?

    respond_to do |format|
      # format.html # show.rhtml
      format.html { redirect_to :controller=>"home", :action=>"index" }
      format.xml  { render :xml => @invitation.to_xml }
    end
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
    @invitation.user_id = current_user.id

    render :layout=>false if request.xhr?
  end

  # GET /invitations/1;edit
  def edit
    @invitation = Invitation.find(params[:id])
  end

  # POST /invitations
  # POST /invitations.xml
  def create
    @invitation = Invitation.new(params[:invitation])

    respond_to do |format|
      if @invitation.save
	   #sending change password email through Resque
        Resque.enqueue(InvitationNotificationWorker, current_user.id,  @invitation.id )
        flash[:notice] = 'Your invitation was sent successfully.' unless request.xhr?
        format.html {
          render :action=>"thanks", :layout=>false and return if request.xhr?
          redirect_to thanks_new_invitation_url and return
        }
        format.xml  { head :created, :location => invitation_url(@invitation) }
      else
        format.html {
          render :action => "new", :layout=>false and return if request.xhr?
          render :action => "new" and return
        }
        format.xml  { render :xml => @invitation.errors.to_xml }
      end
    end
  end

  # PUT /invitations/1
  # PUT /invitations/1.xml
  def update
    @invitation = Invitation.find(params[:id])

    respond_to do |format|
      if @invitation.update_attributes(params[:invitation])
        flash[:notice] = 'Invitation was successfully updated.'
        format.html { redirect_to invitation_url(@invitation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invitation.errors.to_xml }
      end
    end
  end

  # DELETE /invitations/1
  # DELETE /invitations/1.xml
  def destroy
    @invitation = Invitation.find(params[:id])
    @invitation.destroy

    respond_to do |format|
      format.html { redirect_to invitations_url }
      format.xml  { head :ok }
    end
  end
end
