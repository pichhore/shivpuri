class UpdateBuyerProfilesRandom < ActiveRecord::Migration
  def self.up
    buyer_id = ProfileType.find_by_permalink('buyer').id
    Profile.find_all_by_profile_type_id(buyer_id).each do |f|
      rand_str = String.new
      flag = true
      while(!flag.nil?)
        rand_str = Array.new(6){rand(9)}.join
        flag = Profile.find_by_random_string(rand_str)
      end
      Profile.connection.execute("Update profiles set random_string=\"#{rand_str}\" where id=\"#{f.id}\";")
    end
  end

  def self.down
  end
end
