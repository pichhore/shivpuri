class SetDefaultSqueezePageNumber < ActiveRecord::Migration
  def self.up
    #Setting Default squeeze page number for existing records
    users = User.find(:all)
    users.each do |user|
      user_territories = user.user_territories
      if !user_territories.blank?
        i=1
        user_territories.each do |user_territory|
          user_territory.sequeeze_page_number = i
          user_territory.save
          i= i+1
        end  
      end
    end
    
    #setting the user_class UC1 for the users came after 28 Oct 2010.
    uc1_class = UserClass.find(:first,:conditions=>["user_type = 'UC1'"])
    User.update_all("user_class_id = #{uc1_class.id}","created_at >='2010-10-29 00:00:00'") if !uc1_class.blank?

    #change in the territory database
    territory = Territory.find_by_id(13)
    territory.update_attributes(:territory_name => 'Phoenix',:reim_name => 'Phoenix') unless territory.nil?
     
    
  end

  def self.down
  end
end