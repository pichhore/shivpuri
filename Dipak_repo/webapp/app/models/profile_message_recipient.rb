require 'tzinfo'

class ProfileMessageRecipient < ActiveRecord::Base
  uses_guid
  acts_as_paranoid

  belongs_to :profile_message
  belongs_to :from_profile, :class_name => 'Profile', :foreign_key => 'from_profile_id'
  belongs_to :to_profile,   :class_name => 'Profile', :foreign_key => 'to_profile_id'

  # Potentially unused method; only called from profile_messages_controller -> show
  def self.find_for(profile, offset=0, number_to_fetch=10, user_sort_order="profile_messages.created_at DESC")
    sort_order = user_sort_order # place holder for future custom sort order needs
    count = self.count(:all, :conditions=>["to_profile_id = ?", profile.id])
    results = self.find(:all, :conditions=>["to_profile_id = ?", profile.id], :include=>:profile_message, :order => sort_order, :offset=>offset, :limit=>number_to_fetch)

    total_pages = (count / number_to_fetch)
    total_pages += 1 if (count % number_to_fetch) != 0
    total_pages = 1 if total_pages == 0

    return results, total_pages
  end

  # Heavily used
  def self.find_distinct_for(profile, offset=0, number_to_fetch=10, user_sort_order="pmr.viewed_at ASC, pm.created_at DESC", message_filter="all", listing_type="all")
    message_filter = message_filter.downcase
    offset_num = offset
    offset_num = 0 if offset.nil?

    # 1. Obtain a count and (paginated) list of distinct from_profile_ids
    # If any are archived, they're all archived
    archived = "(select 1 from profile_message_recipients pmr2 where pmr2.to_profile_id = pmr.to_profile_id and pmr2.from_profile_id = pmr.from_profile_id and (pmr2.archived = 1))" 
    archived_0 = "(select 1 from profile_message_recipients pmr2 where pmr2.to_profile_id = pmr.to_profile_id and pmr2.from_profile_id = pmr.from_profile_id and (pmr2.archived = 0))"
    unread = "(select 1 from profile_message_recipients pmr2 where pmr2.to_profile_id = pmr.to_profile_id and pmr2.from_profile_id = pmr.from_profile_id or (pmr2.viewed_at is null))"
#    filter_clause = " and (not exists #{archived}) " if message_filter == 'all'
    filter_clause = " and (exists #{archived} or exists #{unread} or exists #{archived_0}) " if message_filter == 'all'
    filter_clause = " and (exists #{unread}) " if message_filter == 'unread'
    filter_clause = " and (exists #{archived}) " if message_filter == 'archived'
    listing_type_join = ''
    if listing_type == 'fsbo'
      listing_type_join = " inner join profiles p on p.id = pmr.from_profile_id and p.profile_type_id = '#{ProfileType.get_guid('owner')}' "
    elsif listing_type == 'listed'
      listing_type_join = " inner join profiles p on p.id = pmr.from_profile_id and p.profile_type_id = '#{ProfileType.get_guid('seller_agent')}' "
    elsif listing_type == 'buyer'
      listing_type_join = " inner join profiles p on p.id = pmr.from_profile_id and p.profile_type_id = '#{ProfileType.get_guid('buyer')}' "
    elsif listing_type == 'buyer_agent'
      listing_type_join = " inner join profiles p on p.id = pmr.from_profile_id and p.profile_type_id = '#{ProfileType.get_guid('buyer_agent')}' "
    end
    

    from_profile_id_results = self.connection.select_all("select pmr.from_profile_id as from_profile_id, pmr.viewed_at as viewed_at, pm.created_at as created_at, pmr.viewed_at, pm.created_at from profile_messages pm, profile_message_recipients pmr #{listing_type_join} where pmr.profile_message_id = pm.id #{filter_clause} and pmr.to_profile_id = '#{profile.id}' AND pmr.deleted_at IS NULL order by #{user_sort_order}")

    # 2. Sort the new messages (viewed_at is null) first, and then by the most recent message
    from_profile_id_results.sort! do |a,b|
      r = b["created_at"] <=> a["created_at"]
      r = -1 if a["viewed_at"].nil? and ! b["viewed_at"].nil?
      r = 1 if b["viewed_at"].nil? and ! a["viewed_at"].nil?
      r
    end
    
    # create a distinct list of profile_ids
    # not sure if uniq! preserves order so doing this manually
    distinct_profile_id_results = Array.new
    unique_set = {}
    from_profile_id_results.each do |row|
      id = row["from_profile_id"]
      distinct_profile_id_results << id if unique_set[id].nil?
      unique_set[id] = 'foo'
    end
    count = distinct_profile_id_results.length
    
    #distinct_profile_id_results.uniq!

    # load up the PMRs into an array for the caller
    results = Array.new
    distinct_profile_id_results.each_with_index do |row, index|
      # manual pagination required for this nasty query (for messages tab on dashboard)
      if index >= offset_num and index < (offset_num + number_to_fetch)
        from_profile_id = row
        #puts "from_profile_id=#{from_profile_id}"
        pmr = self.find(:first, :conditions=>["to_profile_id = ? AND from_profile_id = ?", profile.id, from_profile_id], :order=>"ifnull(viewed_at,sysdate()) DESC, profile_messages.created_at DESC", :include=>:profile_message)
        #puts "pmr=#{pmr.id}" if !pmr.nil?
        results << pmr
      end
    end
    
    total_pages = (count / number_to_fetch)
    total_pages += 1 if (count % number_to_fetch) != 0
    total_pages = 1 if total_pages == 0

    return results, total_pages
  end

  # Called from conversations_controller -> show
  def self.find_from_to(from_profile, to_profile, offset=0, number_to_fetch=10, sort_order="profile_messages.created_at DESC",message_subject=nil)
    count = self.count(:all, :conditions=>["(from_profile_id = ? AND to_profile_id = ?) OR (from_profile_id = ? AND to_profile_id = ?)", from_profile.id, to_profile.id, to_profile.id, from_profile.id])
    
    if message_subject.blank?
      results = self.find(:all, :conditions=>["(from_profile_id = ? AND to_profile_id = ?) OR (from_profile_id = ? AND to_profile_id = ?)", from_profile.id, to_profile.id, to_profile.id, from_profile.id], :include=>:profile_message, :order => sort_order, :offset=>offset, :limit=>number_to_fetch)
    else
       results = self.paginate(:all, :conditions=>["( (from_profile_id = ? AND to_profile_id = ?) OR (from_profile_id = ? AND to_profile_id = ?) )  and (profile_messages.subject = ? or profile_messages.subject = ?)", from_profile.id, to_profile.id, to_profile.id, from_profile.id,message_subject,"Re: "+message_subject], :include=>:profile_message, :order => sort_order, :page => offset, :per_page => number_to_fetch)
    end

    total_pages = (count / number_to_fetch)
    total_pages += 1 if (count % number_to_fetch) != 0
    total_pages = 1 if total_pages == 0

    return results, total_pages
  end

  # Called from reports and digest only
  def self.find_unread_messages(profile, sort_order="profile_messages.created_at DESC")
    return self.find(:all, :conditions=>["to_profile_id = ? and viewed_at IS NULL", profile.id], :include=>:profile_message, :order => sort_order)
  end

  # Not called from anywhere
  def self.find_new_messages_since_last_login(profile, sort_order="profile_messages.created_at DESC")
    return self.find(:all, :conditions=>["to_profile_id = ? and viewed_at IS NULL #{"and profile_messages.created_at >= '#{profile.user.last_login_at.to_formatted_s(:db)}'" if profile.user.last_login_at}", profile.id], :include=>:profile_message, :order => sort_order)
  end

  def self.find_for_message(profile_message, profile)
    return self.find(:all, :conditions=>["profile_message_id = ? AND to_profile_id = ?",profile_message.id, profile.id])
  end

  # Not called from anywhere
  def self.count_new_for(profile)
    # Note: changing from query to find "unread" to "new" by checking against the created_at date on the profile_message
    # count = self.count(:all, :conditions=>["to_profile_id = ? AND viewed_at IS NULL", profile.id])
    count = ProfileMessageRecipient.count_by_sql("select count(pmr.id) as count from profile_message_recipients pmr, profile_messages pm where pmr.profile_message_id = pm.id #{"and pm.created_at >= '#{profile.user.previous_login_at.to_formatted_s(:db)}'" if profile.user.previous_login_at} and to_profile_id = '#{profile.id}' and pmr.viewed_at is null")
    return count
  end

  def self.count_unread_for(profile, listing_type='all')
    includes = []
    if listing_type == 'fsbo'
      listing_type_join = " AND profiles.profile_type_id = '#{ProfileType.get_guid('owner')}' "
    elsif listing_type == 'listed'
      listing_type_join = " AND profiles.profile_type_id = '#{ProfileType.get_guid('seller_agent')}' "
    elsif listing_type == 'buyer'
      listing_type_join = " AND profiles.profile_type_id = '#{ProfileType.get_guid('buyer')}' "
    elsif listing_type == 'buyer_agent'
      listing_type_join = " AND profiles.profile_type_id = '#{ProfileType.get_guid('buyer_agent')}' "
    end
    includes << :from_profile unless listing_type_join.nil?
    count = self.count(:all, :include=>includes, :conditions=>["to_profile_id = ? AND viewed_at IS NULL #{listing_type_join} ", profile.id])
    return count
  end

  def self.count_new_to_from(to_profile_id, from_profile_id)
    count = self.count(:all, :conditions=>["to_profile_id = ? AND from_profile_id = ? AND viewed_at IS NULL", to_profile_id, from_profile_id])
    return count
  end

  def self.count_sent_messages(time)
    # Used for stats
    return ProfileMessageRecipient.count_by_sql("select count(pmr.id) from profile_message_recipients pmr, profile_messages pm where pmr.profile_message_id = pm.id and DATE(pm.created_at) < '#{time.strftime("%Y-%m-%d")}' and pmr.from_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp')) AND pmr.to_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp'))")
    
    #return ProfileMessageRecipient.count_by_sql("select count(pmr.id) from profile_message_recipients pmr, profile_messages pm where pmr.profile_message_id = pm.id and DATE(pm.created_at) < '#{time.strftime("%Y-%m-%d")}'")
  end

  def self.calc_percentage_unread(time)
    total_count = ProfileMessageRecipient.count_by_sql("select count(pmr.id) from profile_message_recipients pmr, profile_messages pm where pmr.profile_message_id = pm.id and DATE(pm.created_at) < '#{time.strftime("%Y-%m-%d")}' and pmr.from_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp')) AND pmr.to_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp'))")
    
    total_unread = ProfileMessageRecipient.count_by_sql("select count(pmr.id) from profile_message_recipients pmr, profile_messages pm where pmr.profile_message_id = pm.id and pmr.viewed_at IS NULL and DATE(pm.created_at) < '#{time.strftime("%Y-%m-%d")}' and pmr.from_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp')) AND pmr.to_profile_id NOT IN (SELECT profiles.id FROM profiles, users WHERE  profiles.user_id = users.id AND users.test_comp IN ('test','comp'))")
    
    #total_unread = ProfileMessageRecipient.count_by_sql("select count(pmr.id) from profile_message_recipients pmr, profile_messages pm where pmr.profile_message_id = pm.id and viewed_at IS NULL and DATE(pm.created_at) < '#{time.strftime("%Y-%m-%d")}'")

    return ((total_unread.to_f / total_count.to_f)*100).to_i unless total_count == 0
    return 0
  end

  def display_from_profile_name
    return self.from_profile.display_name
  end

  def display_from_profile_type
    return self.from_profile.display_type
  end

  def display_subject
    return self.profile_message.display_subject
  end

  def display_sent_at(tz = TZInfo::Timezone.get('America/Chicago'))
    local_time = tz.utc_to_local(self.profile_message.created_at)
    return local_time.strftime("%b %d %Y %I:%M %p")
  end

  def display_message_preview
    return self.profile_message.body[0..99]
  end

  def unread?
    return self.viewed_at.nil?
  end
  
  def mark_as_read!
    self.viewed_at = Time.now
    self.save!
  end

end
