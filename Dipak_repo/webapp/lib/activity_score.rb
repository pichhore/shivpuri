class ActivityScore
  def initialize(logger=Logger.new("#{RAILS_ROOT}/log/activity_score.log"))
    @logger = logger
  end

  def initialize_operations_values
    @number_of_profiles_created = @number_of_profiles_created || Profile.find_with_deleted(:all, :select=>"count(*) as count ,user_id,date(created_at) as created_at_date", :group => 'user_id,date(created_at)')
    @number_of_seller_profiles_created = @number_of_seller_profiles_created || SellerProfile.find(:all, :select=>"count(*) as count ,user_id,date(created_at) as seller_created_at_date", :group => 'user_id,date(created_at)')
    @number_of_profiles_updated = @number_of_profiles_updated || ActivityLog.find(:all, :select=>"count(*) as count ,user_id,date(created_at) as updated_at_date", :conditions => {:activity_category_id => 'cat_prof_updated'}, :group => 'user_id,date(created_at)')
    @number_of_profiles_deleted = @number_of_profiles_deleted || ActivityLog.find(:all, :select=>"count(*) as count ,user_id,date(created_at) as deleted_at_date", :conditions => {:activity_category_id => 'cat_prof_deleted'}, :group => 'user_id,date(created_at)')
    @number_of_messages_send = @number_of_messages_send || User.find_by_sql("select count(*) as count, p.user_id, date(pm.created_at) as send_at_date from profile_message_recipients pmr,profiles as p,profile_messages as pm where pmr.profile_message_id=pm.id and p.id=pmr.from_profile_id and p.user_id is not null group by p.user_id,date(pm.created_at);")
    @number_of_investor_messages_send = @number_of_investor_messages_send || User.find_by_sql("select count(*) as count, u.id, date(im.created_at) as investor_send_at_date from investor_messages im inner join users u on u.id=im.sender_id group by u.id,date(im.created_at);")
    @number_of_messages_read = @number_of_messages_read || User.find_by_sql("select count(*) as count, p.user_id, date(pm.created_at) as read_at_date from profile_message_recipients pmr,profiles as p,profile_messages as pm where pmr.profile_message_id=pm.id and p.id=pmr.to_profile_id and p.user_id is not null and pmr.viewed_at is not null group by p.user_id,date(pm.created_at);")
    @number_of_investor_messages_read = @number_of_investor_messages_read || User.find_by_sql("select count(*) as count, u.id, date(im.created_at) as investor_read_at_date from investor_message_recipients imr,users as u,investor_messages as im where imr.investor_message_id=im.id and u.id=imr.reciever_id and u.id is not null and imr.is_read is true group by u.id,date(im.created_at);")
    @number_of_profiles_viewed = @number_of_profiles_viewed || User.find_by_sql("select count(*) as count, p.user_id, date(pv.created_at) as viewed_at_date from profile_views as pv,profiles as p where pv.viewed_by_profile_id=p.id and p.user_id is not null group by p.user_id,date(pv.created_at);")
  end

def initialize_daily_operations_values
    @number_of_profiles_created = @number_of_profiles_created || Profile.find_with_deleted(:all, :select=>"count(*) as count ,user_id,date(created_at) as created_at_date", :conditions => ["date(created_at) like (?)",(Date.today - 1).to_date ], :group => 'user_id,date(created_at)') 
    @number_of_seller_profiles_created = @number_of_seller_profiles_created || SellerProfile.find(:all, :select=>"count(*) as count ,user_id,date(created_at) as seller_created_at_date", :conditions => ["date(created_at) like (?)",(Date.today - 1).to_date ], :group => 'user_id,date(created_at)')
    @number_of_profiles_updated = @number_of_profiles_updated || ActivityLog.find(:all, :select=>"count(*) as count ,user_id,date(created_at) as updated_at_date", :conditions => [" activity_category_id = ? and date(created_at) like (?)", 'cat_prof_updated',(Date.today - 1).to_date], :group => 'user_id,date(created_at)')
    @number_of_profiles_deleted = @number_of_profiles_deleted || ActivityLog.find(:all, :select=>"count(*) as count ,user_id,date(created_at) as deleted_at_date", :conditions => [" activity_category_id = ? and date(created_at) like (?)",'cat_prof_deleted',(Date.today - 1).to_date], :group => 'user_id,date(created_at)')
  @number_of_messages_send = @number_of_messages_send || User.find_by_sql("select count(*) as count, p.user_id, date(pm.created_at) as send_at_date from profile_message_recipients pmr,profiles as p,profile_messages as pm where pmr.profile_message_id=pm.id and p.id=pmr.from_profile_id and p.user_id is not null and date(pm.created_at) like '#{(Date.today - 1).to_date}' group by p.user_id,date(pm.created_at);")
    @number_of_investor_messages_send = @number_of_investor_messages_send || User.find_by_sql("select count(*) as count, u.id, date(im.created_at) as investor_send_at_date from investor_messages im inner join users u on u.id=im.sender_id and date(im.created_at) like '#{(Date.today - 1).to_date}' group by u.id,date(im.created_at);")
    @number_of_messages_read = @number_of_messages_read || User.find_by_sql("select count(*) as count, p.user_id, date(pm.created_at) as read_at_date from profile_message_recipients pmr,profiles as p,profile_messages as pm where pmr.profile_message_id=pm.id and p.id=pmr.to_profile_id and p.user_id is not null and pmr.viewed_at is not null and date(pm.created_at) like '#{(Date.today - 1).to_date}' group by p.user_id,date(pm.created_at);")
    @number_of_investor_messages_read = @number_of_investor_messages_read || User.find_by_sql("select count(*) as count, u.id, date(im.created_at) as investor_read_at_date from investor_message_recipients imr,users as u,investor_messages as im where imr.investor_message_id=im.id and u.id=imr.reciever_id and u.id is not null and imr.is_read is true and date(im.created_at) like '#{(Date.today - 1).to_date}' group by u.id,date(im.created_at);") 
    @number_of_profiles_viewed = @number_of_profiles_viewed || User.find_by_sql("select count(*) as count, p.user_id, date(pv.created_at) as viewed_at_date from profile_views as pv,profiles as p where pv.viewed_by_profile_id=p.id and p.user_id is not null and date(pv.created_at) like '#{(Date.today - 1).to_date}' group by p.user_id,date(pv.created_at);")
  end

  def get_daily_activity_score(hash, user, date)
    as_num = 0
    as_denom = 21.to_f
    as_num = 6*hash[user][date]["profiles_created"] + 5*hash[user][date]["read_messages"] + 4*hash[user][date]["profiles_deleted"] + 3*hash[user][date]["send_messages"] + 2*hash[user][date]["profiles_viewed"] + hash[user][date]["profiles_updated"]
    if as_num == 0
      return 0
    else
      return as_num/as_denom
    end
  rescue Exception=>exp
    #Taking action if any thing fails
    BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"ActivityScore")
    @logger.info "Error calculating activity score, exp #{exp}"
  end

  def set_hash_values_for_existing_data(hash)
    initialize_operations_values
    pc(hash)
    rm(hash)
    pu(hash)
    pd(hash)
    sm(hash)
    pv(hash)
    return hash
  rescue Exception=>exp
    #Taking action if any thing fails
    BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"ActivityScore")
    @logger.info "Error calculating activity score, exp #{exp}"
  end

  def set_hash_values_for_daily_data(hash)
    initialize_daily_operations_values
    pc(hash)
    rm(hash)
    pu(hash)
    pd(hash)
    sm(hash)
    pv(hash)
    return hash
  rescue Exception=>exp
    #Taking action if any thing fails
    BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"ActivityScore")
    @logger.info "Error calculating activity score, exp #{exp}"
  end

  def get_overall_activity_score(user)
    oas = 0
    oas_denom = 1
    (2..365).each {|i| oas_denom = oas_denom+i}
    DailyActivityScore.all(:conditions => {:user_id => user.id}).each do |das|
      #calulcate time multiplier
      mf = 366 - (Date.today - das.created_at).to_i
      if mf > 0
        oas = oas + mf*das.score
      end
    end
    oas = oas + (2.to_f/21)*upc(user) + (1.to_f/21)*(has_bw(user)+has_sw(user))
    return (oas.to_f/oas_denom)
  rescue Exception=>exp
    #Taking action if any thing fails
    BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"ActivityScore")
    @logger.info "Error calculating overall activity score, exp #{exp}"
  end

  def pc(hash)
    @number_of_profiles_created.each do |record|
      hash["#{record.user_id}"]["#{record.created_at_date}"]["profiles_created"] = record.count.to_i if !hash["#{record.user_id}"].nil? && !hash["#{record.user_id}"]["#{record.created_at_date}"].nil?
    end
    @number_of_seller_profiles_created.each do |record|
      hash["#{record.user_id}"]["#{record.seller_created_at_date}"]["profiles_created"] = hash["#{record.user_id}"]["#{record.seller_created_at_date}"]["profiles_created"] + record.count.to_i if !hash["#{record.user_id}"].nil? && !hash["#{record.user_id}"]["#{record.seller_created_at_date}"].nil?
    end
  end

  def rm(hash)
    @number_of_messages_read.each do |record|
      hash["#{record.user_id}"]["#{record.read_at_date}"]["read_messages"] = record.count.to_i if !hash["#{record.user_id}"].nil? && !hash["#{record.user_id}"]["#{record.read_at_date}"].nil?
    end
    @number_of_investor_messages_read.each do |record|
      hash["#{record.id}"]["#{record.investor_read_at_date}"]["read_messages"] = hash["#{record.id}"]["#{record.investor_read_at_date}"]["read_messages"] + record.count.to_i if !hash["#{record.id}"].nil? && !hash["#{record.id}"]["#{record.investor_read_at_date}"].nil?
    end
  end

  def pd(hash)
    @number_of_profiles_deleted.each do |record|
      hash["#{record.user_id}"]["#{record.deleted_at_date}"]["profiles_deleted"] = record.count.to_i if !hash["#{record.user_id}"].nil? && !hash["#{record.user_id}"]["#{record.deleted_at_date}"].nil?
    end
  end

  def sm(hash)
    @number_of_messages_send.each do |record|
      hash["#{record.user_id}"]["#{record.send_at_date}"]["send_messages"] = record.count.to_i if !hash["#{record.user_id}"].nil? && !hash["#{record.user_id}"]["#{record.send_at_date}"].nil?
    end
    @number_of_investor_messages_send.each do |record|
      hash["#{record.id}"]["#{record.investor_send_at_date}"]["send_messages"] = hash["#{record.id}"]["#{record.investor_send_at_date}"]["send_messages"] + record.count.to_i if !hash["#{record.id}"].nil? && !hash["#{record.id}"]["#{record.investor_send_at_date}"].nil?
    end
  end

  def pv(hash)
    @number_of_profiles_viewed.each do |record|
      hash["#{record.user_id}"]["#{record.viewed_at_date}"]["profiles_viewed"] = record.count.to_i if !hash["#{record.user_id}"].nil? && !hash["#{record.user_id}"]["#{record.viewed_at_date}"].nil?
    end
  end

  def pu(hash)
    @number_of_profiles_updated.each do |record|
      hash["#{record.user_id}"]["#{record.updated_at_date}"]["profiles_updated"] = record.count.to_i if !hash["#{record.user_id}"].nil? && !hash["#{record.user_id}"]["#{record.updated_at_date}"].nil?
    end
  end


  def has_bw(user)
    has_active_bwp = 0
    user_territories = user.user_territories
    unless user_territories.empty?
      user_territories.each do |ut|
        bwp = BuyerWebPage.find(:first,:conditions => {:user_territory_id => ut.id, :active => 1})
        if !bwp.blank?
          has_active_bwp = 1
          break
        end
      end
    end
    if has_active_bwp == 0
      return 0
    else
      return 1
    end
  end

  def upc(user)
    completeness = 0
    if !user.buyer_user_image.blank?
      completeness += 15
    end
       
    if !user.buyer_notification.blank?
      completeness += 20
    end
       
    if !user.user_company_info.blank?
      completeness += 10
    end 
    
    if !user.business_phone.blank?
      completeness += 5
    end 
       
    if !user.about_me.blank?
      completeness += 5
    end
 
    user_focus_investor = user.user_focus_investor.blank? ? UserFocusInvestor.new() : user.user_focus_investor
    if !user_focus_investor.is_longterm_hold.blank? or !user_focus_investor.is_fix_and_flip.blank? or !user_focus_investor.is_wholesale.blank? or !user_focus_investor.is_lines_and_notes.blank?
      completeness += 5
    end 

    if !user.investing_since.blank?
      completeness += 5
    end 

    if !user.real_estate_experience.blank?
      completeness += 5
    end 
    
    if has_bw(user) == 1
      completeness += 30
    end
    completeness = 100 if completeness >= 100
    return completeness/100.to_f
  end

  def has_sw(user)
    sw = SellerWebsite.find(:first, :conditions => {:user_id => user.id,:active => true})
    if sw.blank?
      return 0
    else
      return 1
    end
  end

end
