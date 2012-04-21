module Admin::AdminProfilesHelper
  def owned_by_column(profile)
    link_to(h(profile.owned_by), :action => :show, :controller => '/admin/admin_users', :id => profile.user.id)
  end
  
  def name_column(profile)
    return link_to(h(profile.name), { :action => :preview_buyer, :controller => '/home', :id => profile.id}, :target=>"_new") if profile.buyer?
    return link_to(h(profile.name), { :action => :preview_owner, :controller => '/home', :id => profile.id}, :target=>"_new") if profile.owner?
  end
  
  def profile_name_column(profile)
    name = profile.buyer? ? (profile.private_display_name.include?("Individual") ?  profile.display_name : profile.private_display_name) : profile.display_name
    return link_to(h(name), { :action => :preview_buyer, :controller => '/home', :id => profile.id}, :target=>"_new") if profile.buyer?
    return link_to(h(name), { :action => :preview_owner, :controller => '/home', :id => profile.id}, :target=>"_new") if profile.owner?
  end

  def created_at_column(record)
    record.created_at.nil? ? record.created_at : record.created_at.strftime("%m/%d/%Y %I:%M %p")
  end 
  
  def updated_at_column(record)
    record.updated_at.nil? ? record.updated_at : record.updated_at.strftime("%m/%d/%Y %I:%M %p")
  end
end
