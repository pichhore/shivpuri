class OverallActivityScoreWorker
  
  @queue = :overall_activity_score
  def self.perform()
    logger = logger || Logger.new("#{RAILS_ROOT}/log/overall_activity_score.log")
    logger.info("Date: #{Date.today}")
    activity_score = ActivityScore.new
    users = User.find(:all)
    users.each do |user|
      oas = activity_score.get_overall_activity_score(user)
      if oas != 0
        User.connection.update("UPDATE users set activity_score=#{oas} WHERE id = '#{user.id}'")
        logger.info("Overall Activity Score Details: #{user.id}, #{oas}")
      end
    end 
  end
end
