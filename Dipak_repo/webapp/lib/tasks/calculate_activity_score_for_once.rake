namespace :db do
  desc 'Calculate activity score for existing users'
	task :calculate_activity_score_for_once => :environment do
           Resque.enqueue(CalculateExistingActivityScoreWorker)
	end 
end