require File.dirname(__FILE__) + '/../test_helper'

class MessageEngineTest < Test::Unit::TestCase
  class MockMessageEngine < MessageEngine
    def find_new_matches
      return { 1=> []}
    end
    def find_new_messages
      return { 1=> []}
    end
  end

  def setup
    @emails     = ActionMailer::Base.deliveries
    @emails.clear

    @logger = ActionController::Base.logger
    # @logger = Logger.new(STDOUT)
  end

  #
  # process_user tests
  #

  def test_process_user_should_create_new_history_when_digest_sent
    user = users(:quentin)
    history_count = DigestHistory.count
    engine = MessageEngine.new(Time.now, :daily, @logger)
    history = engine.process_user(user)
    assert_equal history_count+1, DigestHistory.count
    assert_equal user.id, history.user_id
    assert !history.last_process_date.nil?
    assert history.digest_sent?
    assert_equal 1, @emails.length
  end

  def test_process_user_should_skip_deleted_profiles
    user = users(:quentin)
    user.profiles.each { |profile| profile.destroy }
    history_count = DigestHistory.count
    engine = MessageEngine.new(Time.now, :daily, @logger)
    history = engine.process_user(user)
    assert_equal history_count+1, DigestHistory.count
    assert_equal user.id, history.user_id
    assert !history.last_process_date.nil?
    assert !history.digest_sent?
    assert_equal 0, @emails.length
  end

  def DISABLED_test_process_user_should_create_new_history_when_digest_not_sent
    user = users(:quentin)
    fake_history_entry = DigestHistory.new({ :user=>user, :last_process_date=>Time.now.beginning_of_day, :digest_sent_flag=>"T"})
    fake_history_entry.save!

    history_count = DigestHistory.count
    engine = MessageEngine.new(Time.now, :daily, @logger)
    history = engine.process_user(user)
    assert fake_history_entry.id != history.id
    assert_equal history_count+1, DigestHistory.count
    assert_equal user.id, history.user_id
    assert !history.last_process_date.nil?
    assert !history.digest_sent?
    assert_equal 0, @emails.length
  end

  def test_process_user_should_not_sent_digest_if_nothing_new_is_found_daily
    user = users(:quentin)
    history_count = DigestHistory.count
    engine = MockMessageEngine.new(Time.now, :daily, @logger)
    history = engine.process_user(user)
    assert_equal history_count+1, DigestHistory.count
    assert_equal user.id, history.user_id
    assert !history.last_process_date.nil?
    assert !history.digest_sent?
    assert_equal 0, @emails.length
  end

  def test_process_user_should_send_digest_if_something_new_is_found_daily_to_weekly
    user = users(:quentin)

    # standard daily pass
    history_count = DigestHistory.count
    engine = MockMessageEngine.new(Time.now, :daily, @logger)
    history = engine.process_user(user)
    assert_equal history_count+1, DigestHistory.count
    assert_equal user.id, history.user_id
    assert !history.last_process_date.nil?
    assert !history.digest_sent?
    assert_equal 0, @emails.length

    # change to weekly
    user.digest_frequency = 'W'
    user.save!

    # ask the engine to process the user, who was just processed a few sec ago, but now
    # on a weekly basis rather than daily and with new items to email to the user
    # (tests fix for #503)
    history_count = DigestHistory.count
    engine = MessageEngine.new(Time.now, :weekly, @logger)
    history = engine.process_user(user)
    assert_equal history_count+1, DigestHistory.count
    assert_equal user.id, history.user_id
    assert !history.last_process_date.nil?
    assert history.digest_sent?
    assert_equal 1, @emails.length
  end

  def test_digest_email_contents
    user = users(:quentin)
    history_count = DigestHistory.count
    engine = MessageEngine.new(Time.now, :daily, @logger)
    history = engine.process_user(user)
    assert_equal history_count+1, DigestHistory.count
    assert_equal user.id, history.user_id
    assert !history.last_process_date.nil?
    assert history.digest_sent?
    assert_equal 1, @emails.length
    #puts @emails.first.body
  end

  #
  # Date interval tests
  #

  def test_time_to_process_digest_should_always_return_true_if_nil
    engine = MessageEngine.new(Time.now, :daily, @logger)
    time_to_process = engine.__send__("time_to_process_digest?",nil, nil, :daily)
    assert time_to_process
  end

  def test_time_to_process_digest_should_calc_proper_daily_interval
    engine = MessageEngine.new(Time.now, :daily, @logger)

    # 2 days ago
    last_process_time = 2.days.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :daily)
    assert time_to_process

    # 1 day ago
    last_process_time = 1.day.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :daily)
    assert time_to_process

    # 1 day + 1 sec ago
    last_process_time = 1.day.ago
    check_time = 1.day.ago + 1.second
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :daily)
    assert !time_to_process

    # < 1 day ago
    last_process_time = 1.hour.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :daily)
    assert !time_to_process

    # 1 day - 1 sec ago
    last_process_time = 1.day.ago
    check_time = 1.day.ago - 1.second
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :daily)
    assert !time_to_process
  end

  def test_time_to_process_digest_should_calc_proper_weekly_interval
    engine = MessageEngine.new(Time.now, :weekly, @logger)

    # 2 weeks ago
    last_process_time = 2.weeks.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :weekly)
    assert time_to_process

    # 1 week ago
    last_process_time = 1.week.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :weekly)
    assert time_to_process

    # 1 week + 1 day ago
    last_process_time = 1.week.ago
    check_time = 1.week.ago + 1.day
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :weekly)
    assert !time_to_process

    # < 1 week ago
    last_process_time = 1.day.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :weekly)
    assert !time_to_process

    # 1 week - 1 day ago
    last_process_time = 1.week.ago
    check_time = 1.week.ago - 1.day
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :weekly)
    assert !time_to_process

    # 1 week - 1 sec ago
    last_process_time = 1.week.ago
    check_time = 1.week.ago - 1.second
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :weekly)
    assert !time_to_process
  end


  def test_time_to_process_digest_should_calc_proper_monthly_interval
    engine = MessageEngine.new(Time.now, :monthly, @logger)

    # 2 months ago
    last_process_time = 2.months.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert time_to_process

    # 1 month ago
    last_process_time = 1.month.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert time_to_process

    # 1 month + 1 day ago
    last_process_time = 1.month.ago
    check_time = 1.month.ago + 1.day
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert !time_to_process

    # < 1 month ago
    last_process_time = 1.day.ago
    check_time = Time.now
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert !time_to_process

    # 1 month - 1 day ago
    last_process_time = 1.month.ago
    check_time = 1.month.ago - 1.day
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert !time_to_process

    # 1 month - 1 sec ago
    last_process_time = 1.month.ago
    check_time = 1.month.ago - 1.second
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert !time_to_process

    # 1 30-day month ago
    last_process_time = Time.parse("2007-10-31")
    check_time = Time.parse("2007-11-30")
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert time_to_process


    # 29 days ago
    last_process_time = Time.parse("2007-10-30")
    check_time = Time.parse("2007-11-30")
    time_to_process = engine.__send__("time_to_process_digest?",last_process_time, check_time, :monthly)
    assert time_to_process

  end

  #
  # send_messages (end-to-end) tests
  #

  def test_send_messages_should_send_email_for_daily_user_with_new_matches
    results = MessageEngine.send_messages(Time.now, :daily, @logger)
    assert_equal 3, results.length
    assert_equal 1, @emails.length
    assert_equal users(:quentin).id, results[0].user_id
  end

  def test_send_messages_should_process_only_daily_users
    user = users(:quentin)
    user.digest_frequency = 'W'
    user.save!
    user = users(:inactive1)
    user.digest_frequency = 'W'
    user.save!

    results = MessageEngine.send_messages(Time.now, :daily, @logger)
    assert_equal 1, results.length
    assert_equal 0, @emails.length
    assert_equal users(:aaron).id, results[0].user_id
  end

end
