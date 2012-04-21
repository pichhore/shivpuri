module AccountMarketingHelper

  def display_email_description(email_description)
    return User.display_email_assign_values(current_user, email_description.to_s)
  end

  def assign_email_intro
    email_intro = @buyer_notification.email_intro.to_s.gsub("{Business Name}","{Company name}").gsub("{Business Address}","{Company address}").gsub("{Business Phone}","{Company phone}") if !@buyer_notification.email_intro.nil?
  end
  
  def assign_email_closing
    email_closing = @buyer_notification.email_closing.to_s.gsub("{Business Name}","{Company name}").gsub("{Business Address}","{Company address}").gsub("{Business Phone}","{Company phone}") if !@buyer_notification.email_closing.nil?
  end

  def display_email_intro_for_example(summary_type)
    return display_example_values_for_email_desc(BuyerNotification.get_email_intro_for_buyer_responder(summary_type).to_s)
  end

  def display_email_closing_for_example(summary_type)
    return display_example_values_for_email_desc(BuyerNotification.get_email_closing_for_buyer_responder(summary_type).to_s)
  end

  def display_example_for_notification_mail(type)
    return "<div style=\"display:none;\" id=\"#{type}\"/>
            <div style='display:block;' id='overlay_Lightbox'></div>
            <div style='display:block; top:13%; font-family: Arial;' id='lightbox_contract_end_date' style='width: 680px; left:30%;'>
              <div id='streetview_header' style='float:right;'>
                <a href='#' id='streetview_close' onclick='document.getElementById(\"#{type}\").style.display=\"none\";'><img src='/images/active_scaffold/default/close.gif'/></a>
              </div>
              <div id='contract_end_date_contents'>
                <div style='color:black; padding-bottom:15px;'>
                  #{display_email_intro_for_example(type)}
                </div>
                #{"<img src=\"/images/example_1_property.png\" />" if type=="daily"}
                #{"<img src=\"/images/example_email.PNG\" />" if type=="weekly"}
                <div style='color:black; padding-top:15px;'>
                  #{display_email_closing_for_example(type)}
                </div>
              </div>
            </div> </div>"
  end

  def display_email_body_for_example(summary_type)
    return display_example_values_for_email_desc(TrustResponderMailSeries.get_example_for_trust_responder(summary_type).to_s)
  end

  def display_trust_responder_example(type)
    return "<div style='display:none;' class = 'trust_responder_mail' id = \"#{type}\"/>
            <div style='display:block;' id='overlay_Lightbox'></div>
            <div style='display:block; top:13%; font-family: Arial;' id='lightbox_contract_end_date1' style='width: 680px; left:30%;'>
              <div id='streetview_header1' style='float:right;'>
                  <a href='#' id='streetview_close1' onclick='document.getElementById(\"#{type}\").style.display=\"none\";'><img src='/images/active_scaffold/default/close.gif'/></a>
              </div>
              <div id='trust_responder_mail1_contents1'>
                  <div style='color:black; padding-bottom:10px;'>
                    #{display_email_body_for_example(type)}
                  </div>
              </div>
            </div>
            </div>"
  end

  def display_trust_res_email_links(email_number)
    return "<a href='/account_marketing/trust_responder_email_series?email_number=#{email_number}' style=#{@trust_responder_summary_type == "trust_responder_email#{email_number.to_s}" ? 'font-weight:bold' : ''}> Trust Email#{email_number.to_s}</a>"
  end

  def display_note_for_trust_responder
    return "<span style='color:red;'>Note:</span>
        This email series contains an affiliate link to an eBook on Owner Financing, which has been provided by a recommended 3rd party. This eBook is offered to help foster better engagement with your Buyers. You may remove the link or replace with your own, however."
  end

  def display_example_link_for_trust_responder_email(email_number)
    return "<a href='#' onclick=\"document.getElementById('trust_responder_email#{email_number.to_s}').style.display='block';\">Example</a>"
  end

  def display_example_values_for_email_desc(email_desc)
    return email_desc.to_s.gsub("{Investor full name}", "John").gsub("{Company name}","JSK Properties").gsub("{Company address}", "1514 Baines Rd, Suite 305, Austin, TX 78704").gsub("{Company phone}","(512)-555-5555").gsub("{Company email}","john@jsk.com")
  end
end