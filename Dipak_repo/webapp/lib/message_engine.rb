class MessageEngine

  def self.send_messages(starting_time=Time.now, interval=:daily, logger=Logger.new("#{RAILS_ROOT}/log/#{ENV['RAILS_ENV']}.log"))
    begin  
      profile_message_engine = MessageEngine.new(starting_time,interval, logger)
        # Filter user list to process based on user digest settings of the same interval
        # NOTE: users set to (N)ever will always be excluded from the list, so no need to worry
        #       about accidentally sending an email to someone who doesn't want it
        users = User.find_users_with_digest_frequency(interval)
        logger.info("Found #{users.length} users to process")
        histories = Array.new
        users.each do |user|
          begin
            histories << profile_message_engine.process_user(user)
          rescue StandardError, Interrupt =>exp
            BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"MessageEngine")
            logger.info("  error on #{user.id} - #{user.full_name}")
            logger.info "(#{exp.class}) #{exp.message.inspect}"
          end 
        end
        return histories
      rescue Exception => exp
         BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"MessageEngine")
      end
  end

  def initialize(starting_time,interval,logger=Logger.new(STDOUT))
    @starting_time = starting_time
    @interval = interval
    @logger = logger
  end

  def process_user(user, interval=@interval)
    @user = user
    @logger.info("Processing user #{@user.id} - '#{@user.full_name}'")

    # 1. Determine if it is time to process this profile, based on the last digest
    @new_history = DigestHistory.new({ :user=>@user})
    @last_history = DigestHistory.find_last_digest_sent_history(@user)

    if !@last_history.nil? and !@last_history.last_process_date.nil? and !time_to_process_digest?(@last_history.last_process_date, @starting_time, @interval)

      # 2. If not, log and skip
      @new_history.digest_sent_flag = "N"
      @new_history.last_process_date = Time.now
      @new_history.save!
      @logger.info(" skipping - not ready for a new digest yet. Digest recorded as not sent. (ID: #{@new_history.id})")
      return @new_history
    end


    # 3. If so, gather up the data we need and deliver the digest
    digest_sent = deliver_digest

    # 4. Add a digest entry for this digest
    @new_history.digest_sent_flag = (digest_sent == true) ? "Y" : "N"
    @new_history.last_process_date = Time.now
    @new_history.save!

    @logger.info(" digest recorded as sent (ID: #{@new_history.id})")

    # 5. Done!
    return @new_history
  end

  protected

  def time_to_process_digest?(last_process_time, check_time, interval)
    return true if last_process_time.nil?

    if interval == :daily
      if check_time - last_process_time.beginning_of_day >= 1.day
        return true
      end
    end

    if interval == :weekly
      if check_time - last_process_time.beginning_of_day >= 1.week
        return true
      end
    end

    if interval == :monthly
      if check_time - last_process_time.beginning_of_day >= 1.month
        return true
      end
    end

    return false
  end

  def starting_time_as_string
    if @interval == :daily
      return @starting_time.strftime("%B %d, %Y")
    end

    if @interval == :weekly
      return @starting_time.strftime("%B %d, %Y")
    end

    if @interval == :monthly
      return @starting_time.strftime("%B %d, %Y")
    end

  end

  def deliver_digest
    new_matches = find_new_matches
    new_messages = find_new_messages

    new_matches_found = false
    new_matches.each_pair { |profile_id, new_matches_array| new_matches_found = true if !new_matches_array.empty? }

    new_messages_found = false
    new_messages.each_pair { |profile_id, new_messages_array| new_messages_found = true if !new_messages_array.empty? }

    # Did we get anything useful to send?
    if new_matches_found or new_messages_found
      UserNotifier.deliver_digest({ :user=>@user,
                                 :interval=>@interval.to_s,
                                 :date_string=>starting_time_as_string,
                                 :new_matches=>new_matches,
                                 :new_messages=>new_messages
                                })
      @logger.info(" digest sent")
      return true
      # Update the models to mark them as processed, where appropriate
    else
      # No - log and skip
      @logger.info(" skipping - nothing new to digest")
    end

    return false
  end

  def find_new_matches
    return nil if !wants_new_matches?

    results = Hash.new

    @user.active_profiles.each do |profile|
      new_matches, new_matches_count, new_matches_total_pages = MatchingEngine.get_matches(:profile=>profile, :use_cache=>false, :mode=>:all, :result_filter=>:new_email)
      near_new_matches, near_new_matches_count, near_new_matches_total_pages = NearMatchingEngine.get_near_matches(:profile=>profile, :use_cache=>false, :mode=>:all, :result_filter=>:new_email)
      new_matches = new_matches|near_new_matches
      new_matches.uniq!
      results[profile.id] = new_matches
    end

    return results
  end

  def find_new_messages
    return nil if !wants_new_messages?

    results = Hash.new

    @user.active_profiles.each do |profile|
      new_messages = ProfileMessageRecipient.find_unread_messages(profile)
      results[profile.id] = new_messages
    end

    return results
  end

  def find_price_changes
    return nil if !wants_price_changes?

    # ASSUMPTION: only buyers want to see owner price changes (not the other way around)

    results = Hash.new

    return results
  end

  def wants_new_matches?
    # FUTURE: placeholder for finer-grained control of digests
    return true
  end

  def wants_new_messages?
    # FUTURE: placeholder for finer-grained control of digests
    return true
  end

  def wants_price_changes?
    # FUTURE: placeholder for finer-grained control of digests
    return true
  end

end
