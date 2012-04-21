namespace :db do
  task :populate_names => :environment do
    
    puts "updating buyer engagement infos profile ids..."
    i = 0
    BuyerEngagementInfo.find_in_batches(:batch_size => 50) do |batch_records|
      i += 1
      puts "processing buyer engagement batch #{i}..."
      batch_records.each do |f|
        f.profile_id = f.retail_buyer_profile.profile_id
        f.save!
      end
    end
    puts "buyer engagement infos done..."

    i = 0
    ProfileFieldEngineIndex.find_in_batches(:batch_size => 50) do |batch_records|
      i += 1
      puts "processing batch #{i}..."
      batch_records.each do |pfei|
        if pfei.profile
          first_name = ProfileField.find_by_profile_id_and_key(pfei.profile.id, 'first_name').to_s
          pfei.first_name = first_name
          if first_name.blank? && pfei.profile.retail_buyer_profile
            pfei.first_name = pfei.profile.retail_buyer_profile.first_name.to_s
          end
          last_name = ProfileField.find_by_profile_id_and_key(pfei.profile.id, 'last_name').to_s
          pfei.last_name = last_name
          if last_name.blank? && pfei.profile.retail_buyer_profile
            pfei.last_name = pfei.profile.retail_buyer_profile.last_name.to_s
          end
          pfei.save!
        end
      end
      puts "processing batch #{i} complete!!"
    end
  end
end
