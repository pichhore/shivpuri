class UserObserver < ActiveRecord::Observer

  def after_create(user)
    user.reset_perishable_token!
    Delayed::Job.enqueue EmailJob.new(:deliver_activation_instructions!, user)
  end

  def after_update(user)
    # upon activation
    if user.active_changed? and user.active?
      user.roles.create(:title => "user")
      Delayed::Job.enqueue EmailJob.new(:deliver_activation_confirmation!, user)
    end
  end

end
