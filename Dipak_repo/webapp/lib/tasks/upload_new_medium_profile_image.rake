namespace :upload_new_medium_profile_image do
  desc 'create resized profile picture for investor website ( existing user )'
  task :upload_medium_profile_image => :environment do
    users = User.missing_user_profile_images
    puts users.size
    users.each do |user|
      begin
        puts user.full_name
        puts user.id
        buyer_user_image = BuyerUserImage.find_parent_entry_for_prof_pic(user.id)[0]
        next if buyer_user_image.blank?
        puts buyer_user_image.id
        BuyerUserImage.upload_image_for_investor_website(buyer_user_image)
        puts "ok"
      rescue Exception => exp
        puts 'ERROR'
        BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"Error in creating image profile for investor website")
      end
    end
  end
end
