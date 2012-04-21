class ContestController < ApplicationController

  def index
  end

  def terms_and_rules
  end

  def invite
    # get the from info
    from_name  = params[:from_name]
    from_email = params[:from_email]

    total_sent = 0
    # for each invitee, if the invitee doesn't contain the form defaults (for guiding the user), invite them
    params[:invitee][:first_name].each_with_index do |first_name, index|
      to_name   = first_name
      to_email  = params[:invitee][:email][index]
      if to_name != "First Name" and to_email != "Email"
        # actual value, not the default for the form - process it

        # per Damon, create an invitation entry (even though it will never get accepted since the contest sends the
        # recipient to any number of locations within the site)
        ContestInvitation.create!({ :to_name=>to_name, :to_email=>to_email, :from_name=>from_name, :from_email=>from_email, :campaign_code=>"RefCon_Aug08"})

         #sending email through Resque
         Resque.enqueue(ReferralContestInviteNotificationWorker,from_name, from_email, to_name, to_email)
        total_sent += 1
      end
    end if params[:invitee] and params[:invitee][:first_name]

    if total_sent == 0
      flash.now[:form_error] = "hmm, did you forget to add a friend?"
      render :action=>"index" and return
    end

    redirect_to :action=>"thank_you"
  end

  def thank_you
  end
end
