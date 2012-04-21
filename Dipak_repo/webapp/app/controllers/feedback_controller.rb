class FeedbackController < ApplicationController

  # GET new_feedback_url
  def new
    @feedback = Feedback.new
    if logged_in?
      user = current_user
      @feedback.first_name = user.first_name
      @feedback.last_name = user.last_name
      @feedback.email = user.email
    end
  end

  # POST feedback_url
  def create
    # create an feedback
    @feedback = Feedback.new(params['feedback'])
    @feedback.user_id = current_user.id if logged_in?
    @feedback.ip_address = request.env["REMOTE_ADDR"]
    @feedback.cgi_env = YAML::dump(request.env)
    if @feedback.valid?
      begin
        @feedback.save!
        #sending change password email through Resque
        Resque.enqueue(FeedbackSubmittedNotificationWorker, current_user.id, @feedback.id  )
	    redirect_to :action=>"thanks" and return
      rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        puts("#{ e.to_s}")
        handle_error("Sorry, but we could not save your feedback - please try again soon.",e) and return
      end
    end

    render :action=>"new"
  end

  def thanks
  end

  # GET feedback_url
  def show
    render :text=>"'show' Not supported", :status=>500
  end

  # GET edit_feedback_url
  def edit
    render :text=>"'edit' Not supported", :status=>500
  end

  # PUT feedback_url
  def update
    render :text=>"'update' Not supported", :status=>500
  end

  # DELETE feedback_url
  def destroy
    render :text=>"'destroy' Not supported", :status=>500
  end
end
