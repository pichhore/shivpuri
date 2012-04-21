class AddDealDeletedAtForProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :deal_deleted_at, :datetime
    profiles = Profile.find(:all, :conditions => ["profile_delete_reason_id is not null"])
    profiles.each {|profile| profile.update_attributes(:deal_deleted_at => profile.updated_at) }
  end

  def self.down
    remove_column :profiles, :deal_deleted_at
  end
end