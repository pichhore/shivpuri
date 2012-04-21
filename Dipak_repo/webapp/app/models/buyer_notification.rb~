class BuyerNotification < ActiveRecord::Base
  has_many :trust_responder_mail_series, :dependent=>:destroy

  SUMMARY_TYPE = { 'welcome' => "welcome", 'daily' => "daily", 'weekly' => "weekly", 'trust_resp_series' => "trust_resp_series", 'wholesale_welcome' => "wholesale_welcome", 'wholesale_daily' => "wholesale_daily", 'wholesale_weekly' => "wholesale_weekly"}

  BURESPONDER_SUBJECT = { SUMMARY_TYPE['daily'] => "I found some homes that match your needs",
                          SUMMARY_TYPE['welcome'] => "Here's your Free Owner Finance Buyer's Guide!",
                          SUMMARY_TYPE['weekly'] => "Here's a weekly Summary of Homes that match your needs",
                          SUMMARY_TYPE['wholesale_welcome'] => "I’ve Created a Buyer Profile For You!",
                          SUMMARY_TYPE['wholesale_daily'] => "Wholesale Deal Matching Your Criteria!",
                          SUMMARY_TYPE['wholesale_weekly'] => "Wholesale Deal(s) This Week!"
                          }

  BURESPONDER_EMAIL_INTRO = { SUMMARY_TYPE['daily'] => "Hi, this is {Investor full name} with {Company name},
                              <p>Once a day I search for properties that match the criteria you entered into your profile on my website. I only send an email if I find something. Today, I found one or more that match your available down payment and monthly payment, and the area(s) you specified that you are interested in.  Check it out below...</p>",
                              #welcome email intro
                              SUMMARY_TYPE['welcome'] => "<p>Hey {Buyer first name},</p>

                              <p>I want to personally thank you for taking the first step to finding your next Dream Home through Owner Financing!</p>

                              <p>If you haven't downloaded it yet, below is a link to your Free Owner Finance Buyer's Guide...<br />
                              <a href='http://budurl.com/OwnerFinanceGuidev1'>http://budurl.com/OwnerFinanceGuidev1</a>
                              </p>
                              <p>Hopefully, you completed a Buyer Profile for yourself, which will enable us to notify you of homes that match your location and buying criteria.</p>

                              <p>If you haven't yet created a Buyer Profile, just return here and click the Orange button!</p>

                              {buyer website HP}

                              <p>I'll also be sending you some important tips on things to watch out for when buying through Owner Financing...so stay tuned! </p>",
                              #weekly email intro
                              SUMMARY_TYPE['weekly'] => "Once a week, I send an email with the homes I've come across that match your criteria.  You'll get an email from me every Thursday with the current homes that match your payment criteria, location, and amenities.",
                              SUMMARY_TYPE['wholesale_welcome'] => "<p>Hey {Buyer first name},</p>

                              <p>I just wanted to tell you that I have your wholesale buying criteria set up in my database now.</p>

                              <p>As wholesale deals become available, I'll be sending them to you...</p>

                              <p>Here's the Buyer Profile that I have for you...</p>

                              <p>{Buyer criteria}</p>

                              <p>Talk to you soon,</p>

                              {Investor full name}<br />

                              {Company name}<br />

                              {Company address}<br />

                              {Company phone}<br />

                              {Company email}<br /><br />

															P.S. If you need to reach me to change your buying criteria, just give me a buzz at {Company phone} or simply reply to this email!",
                              SUMMARY_TYPE['wholesale_daily'] => "Hey {Buyer first name},
                              <p>I just ran across a property that looks like it may be a match for you..</p>",
                              SUMMARY_TYPE['wholesale_weekly'] => "<p>Once a week on Thursday's, I send an email with any deals I've come across that match your buying criteria. These deals match the location, price, etc that you've specified or communicated to me..</p>"
                                }

  BURESPONDER_EMAIL_CLOSING = { SUMMARY_TYPE['daily'] => "If any of these properties look interesting to you, give me a call at {Company phone} so that we can talk further and I can arrange to possibly show it to you.
                                <p>Thanks,</p
                                <p>{Investor full name}</p>
                                {Company name}<br />
                                {Company address}<br />
                                {Company phone}",
                                #welcome email closing
                                SUMMARY_TYPE['welcome'] => "<p>Remember, we're here to serve you!</p>

                                {Investor full name}<br />

                                {Company name}<br />

                                {Company address}<br />

                                {Company phone}<br />

                                {Company email}<br /><br />

                                P.S. Again, here is the link to create your own personal Buyer Profile, if you haven't already done it!<br />
                                {buyer website HP}",
                                #weekly email closing
                                SUMMARY_TYPE['weekly'] => "Let me know if you see a property that you would like to take a look at.  I look forward to hearing back from you.
                                <p>Thanks,</p>
                                <p>{Investor full name}</p>
                                {Company name}<br />
                                {Company address}<br />
                                {Company phone}",

                             		SUMMARY_TYPE['wholesale_daily'] => "<p>If you are interested, give me a call at {investor phone} or just reply to this email so that we can talk further and I can arrange to possibly show it to you.</p>
                                <p>Thanks,</p>
                                <p>{Investor full name}</p>
                                {Company name}<br />
                                {Company address}<br />
                                {Company phone}",

                              	SUMMARY_TYPE['wholesale_weekly'] => "<p>Let me know if you see a property that you want to take a look at.</p>
                                <p>Thanks,</p>
                                <p>{Investor full name}</p>
                                {Company name}<br />
                                {Company address}<br />
                                {Company phone}" }

  def self.get_buyer_notification(user_id , summary_type)
     buyer_notification = BuyerNotification.find(:first,:conditions => ["user_id LIKE ? and summary_type LIKE ?",user_id,summary_type])
    return buyer_notification unless buyer_notification.nil?
    subject, email_intro, email_closing =  BURESPONDER_SUBJECT[summary_type],  BURESPONDER_EMAIL_INTRO[summary_type], BURESPONDER_EMAIL_CLOSING[summary_type]
    return BuyerNotification.new(:email_intro => email_intro, :email_closing => email_closing, :subject => subject)
  end

  def self.get_email_intro_for_buyer_responder(summary_type)
    return email_intro = BURESPONDER_EMAIL_INTRO[summary_type]
  end

  def self.get_email_closing_for_buyer_responder(summary_type)
    return email_closing = BURESPONDER_EMAIL_CLOSING[summary_type]
  end

  def self.get_buyer_notification_for_trust_responder(user_id , summary_type)
     buyer_notification = BuyerNotification.find(:first,:conditions => ["user_id LIKE ? and summary_type LIKE ?",user_id,summary_type])
    return nil if !buyer_notification.nil? and !buyer_notification.trust_responder_series
    return buyer_notification unless buyer_notification.nil?
    subject, email_intro, email_closing =  BURESPONDER_SUBJECT[summary_type],  BURESPONDER_EMAIL_INTRO[summary_type], BURESPONDER_EMAIL_CLOSING[summary_type]
    return BuyerNotification.new(:email_intro => email_intro, :email_closing => email_closing, :subject => subject)
  end

  def ui_display_details summary_type = nil
    case summary_type
    when "daily"
      ["Use the fields below to customize your Buyer Update Email. This feature will send an update to the email address you specify within a Buyer Profile, only when there is a new property that matches the Buyer Profile. To use this feature, you must Activate it within each Buyer Profile and provide a valid email address. A maximum of one email is sent per day. To see a sample email, click <a href='#' onclick=\"document.getElementById('overlay_Streetview3').style.display='block';\">Example</a>", "Make sure your Company Info is complete before using this feature."]
    when "weekly"
      ["Use the fields below to customize your Buyer Update Summary Email. The Summary Email is sent once a week on Thursdays at 7am CST to each Buyer Profile and includes all property matches to date. To use this feature, you must Activate Buyer Notification within the Buyer Profile and supply a valid Email Address. To see a sample email, click  <a href='#' onclick=\"document.getElementById('overlay_Streetview1').style.display='block';\">Example</a>", "Make sure your Company Info is complete before using this feature."]
    when "welcome"
      ["Use the space below to customize your Buyer Welcome Email. The Welcome Email is sent to new buyers immediately after completing a Buyer Profile and/or opting-in through your squeeze page. To see a sample email, click <a href='#' onclick=\"document.getElementById('overlay_Streetview2').style.display='block';\">Example</a>", "Make sure your Company Info is complete before using this feature."]
    else
      ["The Buyer Trust Responder Series is a 7 part email series, delivered to the Buyer.  It's purpose is to built trust between the buyer and you, by delivering great content and answering some of the common questions regarding Owner Finance transactions.<br><br>    Once activated, one Trust Responder email will be sent the next day after a retail buyer either completes a Buyer Profile or Opts-in to one of your Squeeze Pages.  Emails are sent every other day, until the series is complete.  <br><br>", "This email series contains an affiliate link to an eBook on Owner Financing, which has been provided by a recommended 3rd party.", "To view an email, simply click one of the links below: <br><br><a href='#' onclick=\"document.getElementById('trust_responder_mail1').style.display='block';\">Email1</a><br><a href='#' onclick=\"document.getElementById('trust_responder_mail2').style.display='block';\">Email2</a><br><a href='#' onclick=\"document.getElementById('trust_responder_mail3').style.display='block';\">Email3</a><br><a href='#' onclick=\"document.getElementById('trust_responder_mail4').style.display='block';\">Email4</a><br><a href='#' onclick=\"document.getElementById('trust_responder_mail5').style.display='block';\">Email5</a><br><a href='#' onclick=\"document.getElementById('trust_responder_mail6').style.display='block';\">Email6</a><br><a href='#' onclick=\"document.getElementById('trust_responder_mail7').style.display='block';\">Email7</a>", "Yes"]
    end
  end
end
