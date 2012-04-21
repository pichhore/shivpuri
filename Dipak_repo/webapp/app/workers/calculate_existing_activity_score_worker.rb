class CalculateExistingActivityScoreWorker
  
  @queue = :calculate_existing_activity_score
  def self.perform()
    logger = logger || Logger.new("#{RAILS_ROOT}/log/existing_activity_score.log")
    logger.info("Date: #{Date.today}")
    activity_score = ActivityScore.new
    hash = Hash.new
    users = User.find(:all)
    users.each do |user|
      date_hash = Hash.new()
      (1..((Date.today.to_date - "2010-05-22".to_date).to_i)).each do |day|
        a = Hash.new()
        ["profiles_created", "profiles_updated", "profiles_deleted", "profiles_viewed", "send_messages", "read_messages"].each do |activity|
          a[activity] = 0
        end
        
        date_hash["#{(Date.today - day).to_date}"] = a
      end
      hash["#{user.id}"] = date_hash
    
    end
    DailyActivityScore.destroy_all
    hash = activity_score.set_hash_values_for_existing_data(hash)
    hash.each do |user_id,date_hash|
      date_hash.each do |date, operation_hash|
        das = activity_score.get_daily_activity_score(hash,user_id,date)
        if das != 0
            DailyActivityScore.create(:user_id => user_id, :created_at => date, :score => das)
          logger.info("Daily Activity Score Details: #{user_id}, #{date}, #{das}")
        end
      end
    end
    logger.info("Activity score calculation completed without errors")
  end 
end
