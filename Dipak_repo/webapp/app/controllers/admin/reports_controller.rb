class Admin::ReportsController < Admin::AdminController
  
  def properties
  headers["Content-Type"]="text/xml"
  @profiles = Profile.find(:all,:order=>'created_at DESC')
  render :layout=> false
  end

  def index
  end

  def execute
    @report_name = params[:id]
    @format = params[:format] || "html"

    if params[:start_date]
      @temp_start_date = params[:start_date].gsub("-","/")
      @start_date = Time.parse(@temp_start_date)
    else
      @start_date =  1.day.ago.beginning_of_day
    end
    @start_date_string = @start_date.strftime("%Y-%m-%d")
    @start_date_string_views = @start_date.strftime("%m-%d-%Y")

    if params[:end_date]
      @temp_end_date = params[:end_date].gsub("-","/")
      @end_date = Time.parse(@temp_end_date)
    else
      @end_date = 1.days.from_now.beginning_of_day
    end
    @end_date_string = @end_date.strftime("%Y-%m-%d")
    @end_date_string_views = @end_date.strftime("%m-%d-%Y")
    
    @user_id = params[:user_id]

    # execute the query
    __send__ "#{@report_name}_query"

    # handle CSV case
    if @format == "csv" 
      csv_string = __send__ "#{@report_name}_csv"
      stream_csv("#{@report_name}_report-#{@end_date_string_views}_on_#{Time.now.strftime("%Y-%m-%d_%H_%M_%S")}.csv", csv_string) and return
    end

    # render the HTML format by default
  end

  def edit_delete_comment
    @activity_log = ActivityLog.find_by_id(params[:id])
    @profile = Profile.find_profile_by_id_only(@activity_log.profile_id) if @activity_log.profile_id
    @is_seller_profile = true  if @profile.nil?
    @profile = SellerProfile.find_by_id(@activity_log.seller_profile_id) if @profile.nil?
    render :layout => false
  end

  def update_delete_comment
    @activity_log = ActivityLog.find_by_id(params[:id])
    @profile = Profile.find_profile_by_id_only(@activity_log.profile_id) if @activity_log.profile_id
    @profile = SellerProfile.find_by_id(@activity_log.seller_profile_id) if @profile.nil?
    @profile.update_attribute(:admin_delete_comment, params[:profile][:admin_delete_comment])
    render :text => "ok"
  end

  def error_log
    @errors = LoggedException.find(:all, :conditions => ["date(created_at) between ? and ?", 4.days.ago.to_date, Date.today])
  end
  
  def user_cancellations
    free_class_id = UserClass.free_user
    @users = User.get_canceled_users(free_class_id).paginate :page => params[:page],:per_page => 20
  end

  def total_user_cancellations_csv
    free_class_id = UserClass.free_user
    @users = User.get_canceled_users(free_class_id)
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["First Name","Last Name","Email Login","Date Created","Date Cancelled","Member level","Reason For Cancellation","Hold Offer","Stick Rate"]
      @users.each do |user|
         stick_rate = user.get_individual_stick_rate
         hold_user = user.hold_offer ? "Y" : "N"
         csv << [user.first_name, user.last_name, user.login, user.created_at.strftime("%m/%d/%Y"), user.date_of_cancellation.strftime("%m/%d/%Y"), user.user_class_before_cancellation, user.cancellation_reason, hold_user, stick_rate]
      end
    end
    stream_csv("user_cancellations_csv_report_on_#{Time.now.strftime("%Y-%m-%d_%H_%M_%S")}.csv", csv_string) and return
  end

  protected

  #
  # total_users
  #

  def total_users_query
    # 1. get the list of all users in the system and hash them by ID for quick lookup
    @users = User.paginate(:all, :conditions => ["created_at <= ? and test_comp is null", @end_date], :order => "first_name, last_name", :page => params[:page],:per_page => 20)

    unless @users.empty?
      ids = @users.map{|x| "'#{x.id}'"}.join(',')
      
      # 2. get the count by profile_type for each user
      sql = "SELECT user_id, count(id) as count FROM profiles WHERE profile_type_id = 'ce5c2320-4131-11dc-b431-009096fa4c28' and deleted_at IS NULL AND DATE(created_at) <= '#{@end_date.strftime("%Y-%m-%d")}' AND user_id IN (#{ids}) GROUP BY user_id"
      results = Profile.connection.select_all(sql)
      
      @user_buyer_count_hash = Hash.new
      results.each{|result| @user_buyer_count_hash[result["user_id"]] = result["count"]}
      
      sql = "SELECT user_id, count(id) as count FROM profiles WHERE profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and deleted_at IS NULL AND DATE(created_at) <= '#{@end_date.strftime("%Y-%m-%d")}' AND user_id IN (#{ids}) GROUP BY user_id"
      results = Profile.connection.select_all(sql)
      
      @user_owner_count_hash = Hash.new
      results.each{|result| @user_owner_count_hash[result["user_id"]] = result["count"]}
    end
  end

  def total_users_csv
  @users = User.find(:all, :conditions => ["created_at <= ? and test_comp is null", @end_date], :order => "first_name, last_name")
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["First Name","Last Name","Email", "Last_Login_at", "Created_at", "Activated_at", "Updated_at", "Membership", "Failed Payment", "Activity Score", "# Properties","# BP","# SL"]
      User.find_in_batches(:conditions => ["created_at <= ? and test_comp is null", @end_date], :batch_size => 100) do |batch|

        unless batch.empty?
          ids = batch.map{|x| "'#{x.id}'"}.join(',')
          
          # 2. get the count by profile_type for each user
          sql = "SELECT user_id, count(id) as count FROM profiles WHERE profile_type_id = 'ce5c2320-4131-11dc-b431-009096fa4c28' and deleted_at IS NULL AND DATE(created_at) <= '#{@end_date.strftime("%Y-%m-%d")}' AND user_id IN (#{ids}) GROUP BY user_id"
          results = Profile.connection.select_all(sql)
      
          user_buyer_count_hash = Hash.new
          results.each{|result| user_buyer_count_hash[result["user_id"]] = result["count"]}
      
          sql = "SELECT user_id, count(id) as count FROM profiles WHERE profile_type_id = 'ce5c2320-4131-11dc-b432-009096fa4c28' and deleted_at IS NULL AND DATE(created_at) <= '#{@end_date.strftime("%Y-%m-%d")}' AND user_id IN (#{ids}) GROUP BY user_id"
          results = Profile.connection.select_all(sql)
      
          user_owner_count_hash = Hash.new
          results.each{|result| user_owner_count_hash[result["user_id"]] = result["count"]}
                
          batch.each do |u|
            leads = u.seller_profiles.count unless u.seller_profiles.blank?
            csv << [u.first_name,u.last_name,u.email,format(u.last_login_at),format(u.created_at),format(u.activated_at),format(u.updated_at), "#{u.user_class.user_type_name unless u.user_class.blank?}", "#{u.is_user_have_failed_payment ? "Yes" : ""}", u.activity_score, user_owner_count_hash[u.id] || "0",user_buyer_count_hash[u.id] || "0",leads || "0"]
          end
        end        
      end
    end
  end
  
  #
  # total_messages
  #

  def total_messages_query
    sql = "SELECT u.id as user_id, u.first_name as first_name, u.last_name as last_name, u.email as email, p.id as profile_id, p.name as profile_name, count(pmr.id) as message_count FROM users u, profiles p, profile_message_recipients pmr, profile_messages pm WHERE u.id = p.user_id and p.deleted_at is null and pm.id = pmr.profile_message_id and pmr.from_profile_id = p.id AND DATE(pm.created_at) <= '#{@end_date_string}' AND DATE(pm.created_at) >= '#{@start_date_string}' group by u.id, u.first_name, u.last_name, u.email, p.id, p.name order by message_count DESC"
    @results = Profile.connection.select_all(sql)
  end

  def total_messages_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["First Name","Last Name","Email","Profile Name","# of Messages Sent"]
      @results.each do |result|
        @profile = Profile.find_profile_by_id_only(result["profile_id"])
        @profile.buyer? ? (@profile.private_display_name.include?("Individual") ?  profile_name = @profile.display_name : profile_name = @profile.private_display_name) : profile_name = @profile.display_name
        csv << [result["first_name"], result["last_name"], result["email"], profile_name, result["message_count"]]
      end
    end
  end

  #
  # invite_a_friend
  #

  def invite_a_friend_query
    sql = "SELECT u.first_name as from_first_name, u.last_name as from_last_name, u.email as from_email, i.to_first_name, i.to_last_name, i.to_email, i.created_at, i.accepted_at FROM invitations i, users u WHERE i.user_id = u.id AND DATE(i.created_at) <= '#{@end_date_string}' AND DATE(i.created_at) >= '#{@start_date_string}' ORDER BY from_first_name, from_last_name"
    @results = Invitation.connection.select_all(sql)
  end

  def invite_a_friend_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["From First Name","From Last Name","From Email", "To First Name", "To Last Name", "To Email", "Sent On","Accepted?"]
      @results.each do |result|
        csv << [result["from_first_name"], result["from_last_name"], result["from_email"], result["to_first_name"], result["to_last_name"], result["to_email"], result["created_at"], result["accepted_at"].nil? ? "N" : "Y"]
      end
    end
  end

  #
  # ad_click_through
  #

  def ad_click_through_query
    @ads = Ad.find_all(@end_date_string)

    # views
    sql = "SELECT av.ad_id, count(av.id) as count FROM ad_views av WHERE DATE(av.created_at) <= '#{@end_date_string}' AND DATE(av.created_at) >= '#{@start_date_string}' GROUP BY av.ad_id"
    results = Ad.connection.select_all(sql)
    @ad_view_count_hash = Hash.new
    results.each do |result|
      @ad_view_count_hash[result["ad_id"]] = result["count"]
    end

    # clicks
    sql = "SELECT ac.ad_id, count(ac.id) as count FROM ad_clicks ac WHERE DATE(ac.created_at) <= '#{@end_date_string}' AND DATE(ac.created_at) >= '#{@start_date_string}' GROUP BY ac.ad_id"
    results = Ad.connection.select_all(sql)
    @ad_click_count_hash = Hash.new
    results.each do |result|
      @ad_click_count_hash[result["ad_id"]] = result["count"]
    end

  end

  def ad_click_through_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["Ad Name","Target Page", "Link","# of Views", "# of Clicks", "Click Through Percentage"]
      @ads.each_with_index do |ad, index|
        click_count = @ad_click_count_hash[ad.id].to_f if @ad_click_count_hash[ad.id]
        view_count = @ad_view_count_hash[ad.id].to_f if @ad_view_count_hash[ad.id]

        percentage = (click_count / view_count) * 100 if view_count and click_count
        percentage = 0 unless view_count and click_count

        csv << [ad.name, ad.target_page, ad.link, view_count.to_i || "0", click_count.to_i || "0", "#{percentage.truncate}%"]
      end
    end
  end

  #
  # activity_logs
  #

  def activity_logs_query
    @activity_logs = ActivityLog.find_recent(@start_date_string, @end_date_string)
  end

  def activity_logs_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["Category","Date", "Time", "Description", "User Name", "Profile Name", "Delete Comment", "Support Comment"]
      @activity_logs.each_with_index do |log, index|
        user = User.find_by_id(log.user_id) if log.user_id
        profile = Profile.find_profile_by_id_only(log.profile_id) if log.profile_id
        seller_profile = SellerProfile.find_by_id(log.seller_profile_id) if log.seller_profile_id

        profile_name = log.seller_profile_name.blank? ? ( seller_profile.nil? ? ( profile.nil? ? "" : (profile.buyer? ? (profile.private_display_name.include?("Individual") ?  profile.display_name : profile.private_display_name) : profile.display_name)) : seller_profile.first_name + seller_profile.last_name) : log.seller_profile_name
        delete_comment = seller_profile.nil? ? (( !profile.nil? and log.activity_category.name == "Profile Deleted" ) ? profile.delete_reason :  "") : seller_profile.delete_comment
        support_delete_comment = seller_profile.nil? ? (( !profile.nil? and log.activity_category.name == "Profile Deleted") ? profile.admin_delete_comment :  "") : seller_profile.admin_delete_comment

        csv << [log.activity_category.name, log.created_at.strftime("%Y-%m-%d"), log.created_at.strftime("%I:%M %p"), log.description, user.nil? ? "" : user.full_name, profile_name, delete_comment, support_delete_comment]
      end
    end
  end

  #
  # site_stats
  #

  def site_stats_query
    @site_stats = SiteStat.find_recent(@start_date_string, @end_date_string)
  end

  def site_stats_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["Stat Date", "Stat Type","Value", "Taken On"]
      @site_stats.each_with_index do |stat, index|
        csv << [stat.stats_date.strftime("%Y-%m-%d"), stat.site_stat_type.name, stat.value_num, stat.created_on.strftime("%Y-%m-%d")]
      end
    end
  end

  #
  # profiles
  #

  def profiles_query
    @profiles = Profile.paginate(:all, :conditions => (@user_id.nil? ? {} : {:user_id => @user_id}), :page => params[:page], :per_page => 20)
    @users = User.find_all_users # for drop-down
  end

  def profiles_csv
    # @profiles = Profile.find(:all, :conditions => (@user_id.nil? ? {} : {:user_id => @user_id}))
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["Owned By", "Profile Name", "Created At", "Last Updated At"]

      Profile.find_in_batches(:conditions => (@user_id.nil? ? {} : {:user_id => @user_id}), :batch_size => 250, :include => :user) do |batch|
        batch.each do |profile|
          csv << [profile.user.full_name, profile.display_name, profile.created_at.strftime("%Y-%m-%d"), profile.updated_at.strftime("%Y-%m-%d")]
        end
      end
    end
  end

  #
  # profiles_need_help
  #

  def profiles_need_help_query
    @total_profiles, @profiles = Profile.find_profiles_need_help_admin_reports(params[:page])
  end

  def profiles_need_help_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["Owned By", "Owner Email", "Profile Name", "Profile Type", "Created At", "Last Updated At", "Missing Photos?", "Missing Description?", "Missing Tags>"]
      @profiles.each_with_index do |profile, index|
         profile_user = profile.user
         unless profile_user.nil?
            user_full_name = profile_user.full_name
            profile_user_email = profile_user.email
         else
            user_full_name = ""
            profile_user_email = ""
         end
        csv << [user_full_name, profile_user_email , profile.display_name, (profile.buyer? ? "Buyer" : "Owner"), profile.created_at.strftime("%Y-%m-%d"), profile.updated_at.strftime("%Y-%m-%d"), (profile.buyer? ? ( profile.user.blank? ? "Y" : (profile.user.buyer_user_image.blank? ? "Y" : "N")) : ( profile.profile_images.blank? ? "Y" : "N" )), profile.description.blank? ? "Y" : "N", (profile.buyer? ? "--" : (profile.feature_tags.blank? ? "Y" : "N"))]
      end
    end
  end

  #
  # unread_messages
  #

  def unread_messages_query
    @profiles = Profile.paginate(:all, :order => "users.first_name, users.last_name, profiles.name", :page => params[:page],:per_page => 20, :joins => :user)

    ids = @profiles.map{|x| "'#{x.id}'"}.join(',')

    profile_counts = Profile.connection.select_all("select to_profile_id, count(to_profile_id) as count from profile_message_recipients pmr where to_profile_id IN (#{ids}) group by to_profile_id")
    @total_messages_by_id_hash = Hash.new
    profile_counts.each do |result|
      @total_messages_by_id_hash[result["to_profile_id"].to_s] = result["count"]
    end

    sql = "select to_profile_id, count(to_profile_id) as count from profile_message_recipients pmr where viewed_at is null and deleted_at is null and to_profile_id IN (#{ids}) group by to_profile_id"
    profile_counts = Profile.connection.select_all(sql)
    @unread_counts_by_id_hash = Hash.new
    profile_counts.each do |result|
      @unread_counts_by_id_hash[result["to_profile_id"].to_s] = result["count"]
    end
  end

  def unread_messages_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|
      csv << ["Owned By", "Owner Email", "Profile Name", "Profile Type", "Last User Login", "# Unread Messages", "# Total Received Messages"]
      @profiles.each_with_index do |profile, index|
        csv << [profile.user.full_name, profile.user.email, profile.display_name, (profile.buyer? ? "Buyer" : "Owner"), (profile.user.last_login_at.nil? ? "N/A" : profile.user.last_login_at.strftime("%Y-%m-%d")), @unread_counts_by_id_hash[profile.id.to_s] || "0", @total_messages_by_id_hash[profile.id.to_s] || "0"]
      end
    end
  end


  #
  # contest_invitations
  #
  def contest_invitations_query
    sql = "SELECT * from contest_invitations WHERE DATE(created_at) <= '#{@end_date_string}' AND DATE(created_at) >= '#{@start_date_string}' ORDER BY campaign_code, from_name"
    @results = ContestInvitation.find_by_sql(sql)
  end

  def contest_invitations_csv
    csv_string = FasterCSV.generate(:force_quotes => true) do |csv|


      csv << ["Campaign Code", "From Name", "From Email", "To Name", "To Email", "Sent At", "URL", "Accepted At"]
      @results.each do |result|
        csv << [result.campaign_code, result.from_name, result.from_email, result.to_name, result.to_email, result.created_at, result.first_visited_url, result.accepted_at]
      end
    end
  end

  def format(record)
    record.nil? ? record : record.strftime("%m/%d/%Y %I:%M %p")
  end
end
