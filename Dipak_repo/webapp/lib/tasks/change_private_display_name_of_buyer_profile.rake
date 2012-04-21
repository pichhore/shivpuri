namespace :buyer_profile do
  task :update_buyer_profile_name => :environment do
    begin
      profiles = Profile.find_all_active_buyers
      profiles.each do |profile|
        pfei = profile.profile_field_engine_index
        profile_price_value= profile.is_owner_finance_profile? ? pfei.max_dow_pay : pfei.max_purchase_value
        if ["Single Family Home Individual", "Multi Family Individual", "Multi Family Home Individual", "Condo/Townhome Individual", "Vacant Lot Individual", "Acreage Individual", "Other Individual", "Any Individual"].include?(profile.private_display_name)
          profile.private_display_name = sprintf "%s, %s, %s", profile.private_display_name, profile.investment_type.name, profile_price_value
        else
          if profile.retail_buyer_profile.blank?
            profile.private_display_name = sprintf "%s, %s, %s", profile.private_display_name, profile.investment_type.name, profile_price_value
          else
            profile.private_display_name = sprintf "%s, %s, %s", profile.retail_buyer_profile.first_name, profile.investment_type.name, profile_price_value
          end
        end
        profile.save!
      end
    rescue Exception => exp
      puts "Error"
      BackgroundJobExceptionNotifier.deliver_background_exception_notification(exp,"process_email_rake_file")
    end
  end
end
