class CommunityStats

  FIELDS = [:member_count, :property_count, :private_property_count, :public_property_count, :active_buyers, :public_profiles, :private_profiles, :listed_property_count, :total_profiles]
  create_attrs FIELDS

  def fetch_stats(zip_code=nil)
    zip_condition = zip_code.nil? ? "" : "zip_code = '#{zip_code}' "
    # TODO: cache in DB using a cronjob to update stats
    self.member_count     = "#{ProfileFieldEngineIndex.count(:conditions=>[zip_condition])}" if !zip_condition.empty?
    self.member_count     = "#{ProfileFieldEngineIndex.count()}" if zip_condition.empty?
    zip_condition = " #{zip_condition} AND " if !zip_condition.empty?
    self.property_count   = "#{ProfileFieldEngineIndex.count(:conditions=>[zip_condition+' is_owner = true AND status = "active" AND profile_field_engine_indices.user_id is not null AND (profiles.profile_delete_reason_id not in ("other_owner","other_buyer") OR profiles.profile_delete_reason_id is null)'], :include => [:profile])}"
    self.public_property_count  = "#{ProfileFieldEngineIndex.count(:conditions=>[zip_condition+' is_owner = true AND privacy = "public" AND status = "active" AND profile_field_engine_indices.user_id is not null AND (profiles.profile_delete_reason_id not in ("other_owner","other_buyer") OR profiles.profile_delete_reason_id is null)'], :include => [:profile])}"
    self.private_property_count = "#{ProfileFieldEngineIndex.count(:conditions=>[zip_condition+' is_owner = true AND status = "active" AND (privacy = "private" or privacy is null) AND profile_field_engine_indices.user_id is not null AND (profiles.profile_delete_reason_id not in ("other_owner","other_buyer") OR profiles.profile_delete_reason_id is null)'], :include => [:profile])}"
    self.active_buyers    = "#{ ProfileFieldEngineIndex.count('profile_id',:group=>'profile_id', :conditions=>[zip_condition+' is_owner = false and status = "active" AND profile_field_engine_indices.user_id is not null AND (profiles.profile_delete_reason_id not in ("other_owner","other_buyer") OR profiles.profile_delete_reason_id is null)'], :include => [:profile]).size}"
    self.public_profiles  = "#{ProfileFieldEngineIndex.count(:conditions=>[zip_condition+' privacy = "public" AND profile_field_engine_indices.user_id is not null AND (profiles.profile_delete_reason_id not in ("other_owner","other_buyer") OR profiles.profile_delete_reason_id is null)'], :include => [:profile])}"
    self.private_profiles = "#{ProfileFieldEngineIndex.count(:conditions=>[zip_condition+' (privacy = "private" or privacy is null) AND profile_field_engine_indices.user_id is not null AND (profiles.profile_delete_reason_id not in ("other_owner","other_buyer") OR profiles.profile_delete_reason_id is null)'], :include => [:profile])}"
    self.listed_property_count = 0 # TODO: implement this when MLS flag is supported
    self.total_profiles   = "#{(self.active_buyers.to_i + self.property_count.to_i)}"
  end
end
