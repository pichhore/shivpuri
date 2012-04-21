### This is for generating subscription based report for reimatcher users.
# require "spreadsheet/excel"
class UserActivityBySubscription
=begin 
  def self.generate_activity_report
    user = User.first      
    records = User.find(:all, :conditions => {:user_class_id => 3}, :limit => 50, :order => "activity_score DESC")

    users = []
    records.each do |x|
      users << {:first_name => x.first_name, :last_name => x.last_name, :email => x.email, :activity_score => x.activity_score, :subscription => x.user_class.user_type_name, :business_phone => x.business_phone, :mobile_phone => x.mobile_phone, :no_buyers => no_of_buyers(x), :no_properties => no_of_properties(x), :activated_at => (x.activated_at.to_time if x.activated_at)}
    end
    write_report users
  end
  
  def self.no_of_buyers user
    Profile.find_all_by_user_id_and_profile_type_id(user.id, "ce5c2320-4131-11dc-b431-009096fa4c28").size
  end
  
  def self.no_of_properties user
    Profile.find_all_by_user_id_and_profile_type_id(user.id, "ce5c2320-4131-11dc-b432-009096fa4c28").size
  end

  def self.write_report records
    file = "rei_users_activity_report.xls" 
    workbook = Spreadsheet::Excel.new("#{RAILS_ROOT}/public/#{file}")
    
    worksheet = workbook.add_worksheet("Active Users")
    worksheet.write(0, 0, "First Name")
    worksheet.write(0, 1, "Last Name")
    worksheet.write(0, 2, "E-Mail")
    worksheet.write(0, 3, "Activity Score")
    worksheet.write(0, 4, "Subscription")
    worksheet.write(0, 5, "Business Phone")
    worksheet.write(0, 6, "Mobile Phone")
    worksheet.write(0, 7, "Num. of Buyers")
    worksheet.write(0, 8, "Num. of Properies")
    worksheet.write(0, 9, "Activated At")
    
    row = 1
    records.each do |order|
      worksheet.write(row, 0, "#{order[:first_name]}")
      worksheet.write(row, 1, "#{order[:last_name]}")
      worksheet.write(row, 2, "#{order[:email]}")
      worksheet.write(row, 3, "#{order[:activity_score]}")
      worksheet.write(row, 4, "#{order[:subscription]}")
      worksheet.write(row, 5, "#{order[:business_phone]}")
      worksheet.write(row, 6, "#{order[:mobile_phone]}")
      worksheet.write(row, 7, "#{order[:no_buyers]}")
      worksheet.write(row, 8, "#{order[:no_properties]}")
      worksheet.write(row, 9, "#{order[:activated_at]}")
      row += 1
    end
     
    workbook.close
  end


  def self.generate_inactive_users_report
    records = User.find(:all, :conditions => ["activation_code IS NOT NULL"])

    users = [] 
   

    records.each do |x|
      users << {:first_name => x.first_name, :last_name => x.last_name, :email => x.email, :business_phone => x.business_phone, :mobile_phone => x.mobile_phone, :last_login_at => x.last_login_at.to_s, :created_at => x.created_at.to_s, :user_class_id => x.user_class.user_type_name}
    end

    puts users.map{|x| x[:user_class_id]}.inspect

    file = "rei_inactive_users_report.xls" 
    workbook = Spreadsheet::Excel.new("#{RAILS_ROOT}/public/#{file}")
    
    worksheet = workbook.add_worksheet("Active Users")
    worksheet.write(0, 0, "First Name")
    worksheet.write(0, 1, "Last Name")
    worksheet.write(0, 2, "E-Mail")
    worksheet.write(0, 3, "Business Phone")
    worksheet.write(0, 4, "User Class")
    worksheet.write(0, 5, "Last Login At")
    worksheet.write(0, 6, "Created At")

    row = 1
    users.each do |order|
      worksheet.write(row, 0, "#{order[:first_name]}")
      worksheet.write(row, 1, "#{order[:last_name]}")
      worksheet.write(row, 2, "#{order[:email]}")
      worksheet.write(row, 3, "#{order[:business_phone]}")
      worksheet.write(row, 4, "#{order[:user_class_id]}")
      worksheet.write(row, 5, "#{order[:last_login_at]}")
      worksheet.write(row, 6, "#{order[:created_at]}")
      row += 1
    end
     
    workbook.close
  end

  def self.generate_old_websites_report
    # records = User.find(:all, :conditions => ["activation_code IS NOT NULL"])
    records = BuyerWebPage.find(:all, :conditions => ["domain_permalink_text IS NULL"])

    users = [] 
   

    records.each do |x|
      user = x.user_territory.user
      users << {:first_name => user.first_name, :last_name => user.last_name, :email => user.email, :business_phone => user.business_phone, :mobile_phone => user.mobile_phone, :last_login_at => user.last_login_at.to_s, :user_class_id => user.user_class.user_type_name, :buyer_site_url => "http://reimatcher.com/#{x.user_territory.reim_name}/#{x.permalink_text}"}
    end


    file = "rei_old_buyersites_report.xls" 
    workbook = Spreadsheet::Excel.new("#{RAILS_ROOT}/public/#{file}")
    
    worksheet = workbook.add_worksheet("Active Users")
    worksheet.write(0, 0, "First Name")
    worksheet.write(0, 1, "Last Name")
    worksheet.write(0, 2, "E-Mail")
    worksheet.write(0, 3, "Business Phone")
    worksheet.write(0, 4, "Mobile Phone")
    worksheet.write(0, 5, "Last Login At")
    worksheet.write(0, 6, "User Class")
    worksheet.write(0, 7, "Buyer Site URL")
    row = 1
    users.each do |order|
      worksheet.write(row, 0, "#{order[:first_name]}")
      worksheet.write(row, 1, "#{order[:last_name]}")
      worksheet.write(row, 2, "#{order[:email]}")
      worksheet.write(row, 3, "#{order[:business_phone]}")
      worksheet.write(row, 4, "#{order[:mobile_phone]}")
      worksheet.write(row, 5, "#{order[:last_login_at]}")
      worksheet.write(row, 6, "#{order[:user_class_id]}")
      worksheet.write(row, 7, "#{order[:buyer_site_url]}")
      row += 1
    end
     
    workbook.close
  end
=end
  
  def self.update_tou_acceptance
    User.all.each do |x|
      first_login = ActivityLog.find(:first, :conditions =>{:activity_category_id => 'cat_acct_login', :user_id => x.id}, :order => 'created_at ASC')
      if first_login
        x.update_attributes({:user_status => "Terms Accepted", :tou_accepted_at => first_login.created_at})
      end
    end
  end

  def self.update_tou_acceptance_for_empty
    User.all.select{|x| x.tou_accepted_at.nil?}.each do |x|
      first_login = ActivityLog.find(:first, :conditions =>{:activity_category_id => 'cat_acct_login', :user_id => x.id}, :order => 'created_at ASC')
      if first_login
        x.update_attributes({:user_status => "Terms Accepted", :tou_accepted_at => first_login.created_at})
      end
    end
  end 
end
 
