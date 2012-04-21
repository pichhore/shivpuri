# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  APPLICATION_STATUS={"approved" => "green ", "pending"=> "orange ", "rejected"=>"red ", "paid" => "blue ", "cancelled" => "red ", "moved_in" =>"red "}

  def flash_helper
    f_names = [:notice, :warning, :message]
    fl = ''

    for name in f_names
      if flash[name]
        fl = fl + "<p id=\"flash\" class=\"#{name}\">#{flash[name]}</p>"
      end
      flash[name] = nil;
    end
    return fl
  end

  def reset_flash_helper
    f_names = [:notice, :warning, :message]
    fl = ''
    for name in f_names
      if flash[name]
        fl = fl + "<div id=\"errorExplanation\" class=\"errorExplanation\"><h2>Opps! There are problems with your information.</h2><ul><li>#{flash[name]}</li></ul></div>"
      end
      flash[name] = nil;
    end
    return fl
  end

  def move_in_date(date)
    boxy_date_format date
  end

  def move_out_date(date1, date2)
    date = date1 + date2.to_i.months
    boxy_date_format date
 end

  def number_to_ordinal(num)
    num = num.to_i
    if (10...20)===num
      "#{num}th"
    else
      g = %w{ th st nd rd th th th th th th }
      a = num.to_s
      c=a[-1..-1].to_i
      a + g[c]
    end
  end

  def boxy_date_format(date)
    unless date.nil?
      str = String.new
      str << date.strftime("%A, ")
      str << number_to_ordinal (date.strftime("%d"))
      str << date.strftime(" %B %Y")
      return str
    end
  end
  

  def boxy_date_format_for_account(date)
    return "N/A" if date.blank?
    str = String.new
    str << date.to_date.strftime("%d")
    str << date.to_date.strftime(" %B %Y")
    return str
  end

  def message_sent_at(date)
    str = boxy_date_format_for_account(date)
    str << date.strftime(" %I:%M%p ") unless str=="N/A"
  end

  def get_property_application(property)
    @application = property.applications.find_by_status("paid")
  end
  
  def duration_in_hours(date)
    duration = (Time.now - date)
    dur = duration.to_i / (60 * 60 )
    return dur
  end

  def payment_date_limit(date1)
    date = date1 + (48).hours
    boxy_date_format_for_account date
 end

 def duration_left_to_pay(date)
  duration = (Time.now - date)
    dur = duration.to_i / (60 * 60 )
    return (48-dur)
 end

  def count_rented_property(properties)
    count = 0
    properties.each do |property|
      if (property.status == "paid" and check_status_receive_payment(property))
        count += 1
      end
    end
    return count
  end

  def selected_method(str1,str2)
    if str1==str2
      return "selected"
    end
    return "nonselected"
  end

  def member_since(date)
    str = String.new
    str << date.strftime(" %m/%Y")
    return str
  end
 def application_count(applications)
    return applications.pending.count
 end
  
  def check_status_held_payment( property)
    application = property.applications
    application.each do |app|
      if  app.payment_transfer_status == true
        return false
      end
    end
    return true
  end


  def total_held_by_boxyroom(occupied_properties)
    total_held = 0;
    occupied_properties.each do|occ_prop|
      if  check_status_held_payment(occ_prop)
        total_held  =  total_held + CurrencyExchange.currency_exchange( payment_to_landlord(occ_prop.monthly_rental) , occ_prop.currency_type.nil? ? "USD" : occ_prop.currency_type , occ_prop.owner.prefers_currency).to_i
      end
    end
    return total_held 
  end
  
  def check_status_receive_payment( property)
    application = property.applications
    application.each do |app|
      if  app.payment_transfer_status == true
        return true
      end
    end
    return false
  end

  def total_received_to_date(occupied_properties)
    total_received = 0
    occupied_properties.each do|occ_prop|
      if  check_status_receive_payment(occ_prop)
        total_received =  total_received + CurrencyExchange.currency_exchange_local( payment_to_landlord(occ_prop.monthly_rental) , occ_prop.currency_type.nil? ? "USD" : occ_prop.currency_type , occ_prop.owner.prefers_currency).to_i
      end
    end
    return total_received
  end

  def total_occupied_properties(occupied_properties)
    total_occupied = 0;
    occupied_properties.each do|occ_prop|
      if  check_status_receive_payment(occ_prop)
        total_occupied = total_occupied + 1;
      end
    end
    return total_occupied
  end

  def unread_messages(mess)
    unread_messages = 0
    mess.each do |message|
      unread_messages += 1 if message.unread?
    end
    return unread_messages
  end

  def check_user_like_property_status(property)
    property.like_properties.each do|lp|
     return true if lp.user_id == current_user.id
    end
    return false
  end

  def property_likes_count(property)
    return property.like_properties.count
  end

   def property_review_count(property)
    return property.reviews.count
  end

  def verified_property(property)
    return true if property.verified?
  end

  def payment_type(app)
    if  app.credit_card_information.nil?
      return "Paypal"
    end
    card_no = mask_number(app.credit_card_information.cardno)
    return "Creditcard"+card_no
  end

  def mask_number(number)
   return number.to_s.size < 5 ? number.to_s : (('*' * number.to_s[0..-5].length) + number.to_s[-4..-1])
  end

  def boxyroom_fees(rental_amount)
   return (rental_amount * BOXYROOM_ADMIN_FEE)
  end

  def payment_to_landlord(rental_amount)
   return (rental_amount * PAYMENT_TO_LANDLRD)
  end

  def payment_status_view( status )
    span_class = APPLICATION_STATUS[status.to_s]
    return "<span class='status #{span_class} #{status.to_s}'></span>"
  end

  def flash_message
    render :partial=>"shared/flash_message"
  end

  def can_write_review(application)
    if  application.moved_in? and !application.paid_at.nil?
     application.review.nil? and (application.expected_arrival <= Date.today) and ((Date.today - 2)>  (application.paid_at.time).to_date)
    else
      return false
    end
  end
  
  def return_currency_abbrebiation(currency)
   return CURRENCIES[currency]
  end

  def all_listed_property
    Property.listed.count
  end

  def all_users
    User.all.count
  end
  
  def dialouge_with(thread)
    return thread.participant.full_name if thread.owner == current_user
    return thread.owner.full_name 
  end
  
  def change_option user
   return  user.roles[0].nil? ? false :  user.roles[0].title == 'user'
  end

  def change_permission user
    !user.suspended? and user != current_user and user.active
  end

  def is_admin user
   return user.full_name+"*"if user.active && user.roles[0].title == 'admin'
   return user.full_name
  end
  
  def is_in_pending_verification(property)
  	property.status == 'listed' && PropertyDoc.find_by_property_id(property.id)
  end
  
end
