class ConversationsController < ApplicationController
  before_filter :login_required
  before_filter :load_profile
  before_filter :load_target_profile, :except=>[:create]
  before_filter :check_profile_ownership

  #before_filter :check_investor_role, :only=>["create"]
#   before_filter :only=>["create"] do  |controller|  
#     controller.send(:check_investor_role,[BASIC_USER_CLASS[:uc1_type],BASIC_USER_CLASS[:uc2_type]])
#   end

  layout "application"

  RESULTS_PER_PAGE = 10

  # GET /profiles/<profile_id/conversations/
  # GET /profiles/<profile_id/conversations.xml
  def index
    render :text=>"index not supported", :status=>500
  end

  # GET /profiles/<profile_id/conversations/<profile_id>
  # GET /profiles/<profile_id/conversations/<profile_id>.xml
  def show
    @message_filter = params[:message_filter] || "All"
    @profile_message_form = ProfileMessageForm.new
    @profile_inbox_message = params[:profile_inbox_message]
    @profile_message_id = params[:profile_inbox_message_id]
    message_subject = params[:profile_inbox_message].gsub("&amp\;", '&') if !params[:profile_inbox_message].blank?
    # fetch the paginated messages
    @page_number = (params[:page_number] || "1").to_i
    @offset = @page_number == 1 ? nil : (@page_number-1) * RESULTS_PER_PAGE
    
    if params[:profile_inbox_message].blank?
      @profile_message_recipients, @total_pages = ProfileMessageRecipient.find_from_to(@target_profile, @profile, @offset, RESULTS_PER_PAGE) 
    else
      @profile_message_recipients, @total_pages = ProfileMessageRecipient.find_from_to(@target_profile, @profile, params[:page], RESULTS_PER_PAGE,"profile_messages.created_at DESC",message_subject) 
      if !params[:profile_message_recipient_id].blank?
        profile_message_recipient = ProfileMessageRecipient.find_by_id(params[:profile_message_recipient_id])
        profile_message_recipient.mark_as_read! if profile_message_recipient.to_profile.user_id == current_user.id
      end
    end

    # mark all messages as read that have a to_profile_id == @profile.id
    @marked_as_new = Array.new
    @profile_message_recipients.each do |pmr|
      if pmr.unread? and pmr.to_profile_id == @profile.id
        pmr.mark_as_read!
        @marked_as_new << pmr
      end
    end
    render :layout=>false if !params[:profile_inbox_message].blank?
  end

  # GET /profiles/<profile_id/conversations/new
  def new
    render :text=>"new not supported", :status=>500
  end

  # GET /profiles/<profile_id/conversations/1;edit
  def edit
    render :text=>"edit not supported", :status=>500
  end

  # POST /profiles/<profile_id/conversations
  # POST /profiles/<profile_id/conversations.xml
  def create
    @profile_message_form = ProfileMessageForm.new
    @profile_message_form.from_hash(params[:profile_message_form])
    @profile_message_form.send_to = 'indiv'

    # get the values needed by the show action, in case validation fails
    @target_profile = Profile.find_by_id(@profile_message_form.indiv_profile_id)

    if @profile_message_form.valid?
      @profile_message = @profile_message_form.to_profile_message(@profile)
      begin
        unless @profile_message.blank?
          @profile_message[0].save!
          ProfileMessageDeleteHistory.destroy_all(["(subject=? ) and deleted_by=? and (sender =? or sender = ?)", params[:profile_message_from][:message_id], @target_profile.user_id,@target_profile.id, params[:profile_message_form][:from_profile_id]]) if !params[:profile_message_from].blank?
          Resque.enqueue(DirectMessageNotificationWorker, @profile_message[0].profile_message_recipients.first.id )
          render :partial=>"conversation_message", :object => @profile_message[0].profile_message_recipients.first and return
        end
      rescue  Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        handle_error("Error creating your message. The message has not been delivered to the recipient at this time.",e) and return
      end
    end

    #render hash_for_profile_conversation_path(:id=>@profile.id, :profile_id=>@profile_message_form.indiv_profile_id, :page_number=>@page_number)
      if !params[:profile_message_from].blank?
           render :partial=>"reply_form", :status=>401,:locals=>{:subject=>params[:profile_message_form][:subject], :div_id=>"reply_form_" + params[:profile_message_form][:reply_to_profile_message_id], :reply_to_profile_message_id=>params[:profile_message_form][:reply_to_profile_message_id]}
      else
           render :partial=>"create_form", :status=>401
      end 
  end

  # PUT /profiles/<profile_id/conversations/1
  # PUT /profiles/<profile_id/conversations/1.xml
  def update
    render :text=>"update not supported", :status=>500
  end

  # DELETE /profiles/<profile_id/conversations/1
  # DELETE /profiles/<profile_id/conversations/1.xml
  def destroy
    render :text=>"destroy not supported", :status=>500
  end
end
