require 'exception_notifier'

class ExceptionNotifier
  alias_method :old_exception_notification, :exception_notification
  def exception_notification(exception, controller, request, data={})
    bot = Marshmallow.new(:domain => 'yourdomain', :ssl=>true)
    bot.login( :method => :login,
        :username => "notify@yourdomain.com",
        :password => "passw0rd",
        :ssl => true,
        :room => "12345"
      )
    bot.say("EXCEPTION: #{controller.class.to_s} #{request.params[:action]} : #{exception.to_s}")
    bot.paste(data.to_a.join("\n"))
    old_exception_notification(exception, controller, request, data)
  end
end
