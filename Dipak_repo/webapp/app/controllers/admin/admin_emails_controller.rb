class Admin::AdminEmailsController < Admin::AdminController
  active_scaffold :smtp_notification do |config|
    config.actions.exclude :create, :update, :show
  end

  def update_table
    @total_bounced_emails = SmtpNotification.find(:all,:conditions=>["event = 'bounce' and created_at > ?",(Date.today-2.days).to_s(:db)]).size
    @total_delivered_emails = SmtpNotification.find(:all,:conditions=>["event = 'delivered' and created_at > ?",(Date.today-2.days).to_s(:db)]).size
    @bounced_emails = SmtpNotification.paginate(:all,:page => params[:page])
    @total_emails = SmtpNotification.find(:all).size
  end

end
