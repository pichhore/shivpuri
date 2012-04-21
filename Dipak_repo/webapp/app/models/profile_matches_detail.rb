class ProfileMatchesDetail < ActiveRecord::Base
  uses_guid

  class << self
    def match_exists?(profile)
      profile_matches = self.find(:all, 
                                  :conditions => ["source_profile_id = (?) or target_profile_id = (?)", profile.id, profile.id]
                                  )
      return profile_matches
    end
    
    def exact_match_exists?(profile)
      profile_matches = self.find(:all, 
                                  :conditions => ["(source_profile_id = (?) or target_profile_id = (?)) && is_near=0", profile.id, profile.id]
                                  )
      return profile_matches
    end
    
    def near_match_exists?(profile)
      profile_matches = self.find(:all, 
                                  :conditions => ["(source_profile_id = (?) or target_profile_id = (?)) && is_near=1", profile.id, profile.id]
                                  )
      return profile_matches
    end
    
    def add_total_matches(exact_matched_profile, near_matched_profile, profile)

      unless exact_matched_profile.empty?
        exact_matched_profile.each do |matching_profile|
          p_id = matching_profile
          if p_id
            ProfileMatchesDetail.add_exact_match(profile.id, p_id.id)
          #  pmc = ProfileMatchesCount.find_by_profile_id(p_id.id)
          #  if pmc
          #    pmc.increase
          #  end
          #  exact_profile_match_count = ProfileMatchesCount.find_by_profile_id(profile.id)
          #  exact_profile_match_count.increase unless exact_profile_match_count.nil?
          end
        end
      end
      unless near_matched_profile.empty?
        near_matched_profile.each do |near_matching_profile|
          p_id = near_matching_profile
          if p_id
            ProfileMatchesDetail.add_near_match(profile.id, p_id.id)
         #   near_pmc = ProfileMatchesCount.find_by_profile_id(p_id.id)
         #   if near_pmc
         #     near_pmc.increase
         #   end
        #    near_profile_match_count = ProfileMatchesCount.find_by_profile_id(profile.id)
        #    near_profile_match_count.increase unless near_profile_match_count.nil?
          end
        end
      end
    end

    def add_exact_match(source_profile_id, target_profile_id)
      self.create(:source_profile_id => source_profile_id, :target_profile_id => target_profile_id)
    end
    
    def add_near_match(source_profile_id, target_profile_id)
      self.create(:source_profile_id => source_profile_id, :target_profile_id => target_profile_id, :is_near => true)
    end

    def save_profile_matches_data(profile)
      exact_matched_profile, exact_match_count, exact_match_total_pages = MatchingEngine.get_matches( :profile=>profile, :mode => "all", :result_filter => "all")
      exact_matched_profile = exact_matched_profile.uniq
      if (profile.is_wholesale_profile? or profile.is_wholesale_owner_finance_profile?)
        near_matched_profile, near_match_count, near_match_total_pages = [], 0, 0
      else
        near_matched_profile, near_match_count, near_match_total_pages = NearMatchingEngine.get_near_matches(:profile=>profile, :mode => "all", :result_filter => "all", :number_to_fetch => 1000000)
        near_matched_profile = near_matched_profile.delete_if { |nmp| exact_matched_profile.index(nmp) }.uniq
      end
      
      # Ticket #690, table caching implementation for existing profiles
      profile_match_count = ProfileMatchesCount.find_by_profile_id(profile.id)
      profile_match_count.destroy unless profile_match_count.nil?
      
      ProfileMatchesCount.create(:profile_id => profile.id, :count => 0, :status => true)
      
      profile_matches = ProfileMatchesDetail.match_exists?(profile)
      
      if profile_matches.empty?
        ProfileMatchesDetail.add_total_matches(exact_matched_profile, near_matched_profile, profile )
      else
        profile.delete_profile_matches_data(profile_matches)
        ProfileMatchesDetail.add_total_matches(exact_matched_profile, near_matched_profile, profile )
      end
    end
  end
end
