class Admin::AdminProfilesController  < Admin::AdminController
   active_scaffold :profile do |config|
    config.columns.add :owned_by
    config.columns.add :profile_name 
    config.columns.add :owner_email
    config.columns.add :delete_reason_for_profile
    config.columns[:profile_name].label = "Name"
    config.columns[:delete_reason_for_profile].label = "Delete Reason"
    list.columns = [:profile_name, :owned_by, :owner_email, :created_at, :updated_at, :marked_as_spam, :delete_reason_for_profile, :profile_delete_date]
    #list.sorting = {:target_page => 'ASC'}
    config.columns = [:name, :owner_email]
    #columns[:link].description = "Full URL - e.g. http://www.dwellgo.com"
    config.actions.exclude :create, :update, :show
    config.search.columns << :user
    config.columns[:user].search_sql = "CONCAT(users.first_name, ' ', users.last_name, ' ', users.email)"
    config.columns[:user].includes  = :user
    config.search.columns.exclude :id, :user_id, :profile_type_id, :permalink, :profile_delete_reason_id
  end
end

