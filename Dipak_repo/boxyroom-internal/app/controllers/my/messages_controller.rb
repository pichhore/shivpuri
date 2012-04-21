class My::MessagesController < ApplicationController
  before_filter :require_user

  filter_access_to :all

  def index
    @thread = current_user.all_threads.first

    if @thread.nil?
      flash[:notice] = "Sorry, you do not have any messages."
      redirect_to my_dashboard_my_account_path
    else
      redirect_to my_message_path(@thread.code)
    end
    
  end

  def show
    @thread = MessageThread.find_by_code(params[:id])
    if @thread.nil? || (@thread.owner != current_user && @thread.participant != current_user)
      raise ActiveRecord::RecordNotFound
    else
      @thread.messages.each do |m|
        if m.recipient_id == current_user.id
	 m.update_attributes(:status => "read")
	end
      end
      @new_message = current_user.sent_messages.new do |m|
        m.subject = @thread.title
        if @thread.owner == current_user
          m.recipient_id = @thread.participant.id
        else
          m.recipient_id = @thread.owner.id
        end
    end
    end
    @selected_tab = "Messages"
    render :layout=>"new/application"
  end

  def new
    @message = current_user.sent_messages.new do |m|
      m.recipient_id = params[:to]
    end
    @selected_tab = "Messages"
    render :layout=>"new/application"
  end

  def create
    # craft the message
    
    @message = current_user.sent_messages.new(params[:message]) do |m|
      m.sent_at = Time.now
      m.status = "unread"
    end

    # find or create an existing thread

    @thread = current_user.owned_threads.find_by_participant_id(@message.recipient.id)
    @thread ||= current_user.participating_threads.find_by_owner_id(@message.recipient.id)

    @thread ||= current_user.owned_threads.new do |t|
      t.participant_id = @message.recipient.id
      t.title = @message.subject
    end

    # add the new message to the thread

    @message.thread = @thread

    Message.transaction do
      @message.save
      @thread.save
    end

    if @message.errors.empty? && @thread.errors.empty?
      redirect_to my_message_path(@thread.code)
    else
      sequence = Array.[]('body')
      sequence_e = error_messages_in_sequence(@message.errors, sequence)
      @message.errors.clear
      sequence_e.each do |mess|
	@message.errors.add_to_base(mess)
      end
      @selected_tab = "Messages"
      render :action=> 'new', :layout=>"new/application"
    end
  end

end
