class SetPrivateDisplayNameToDefaultValue < ActiveRecord::Migration
  def self.up
    # for owners, assign the address with zip
    say "Updating owner profiles"

    # paginate 10 at a time, ask the observer to update the indices
    offset = 0
    per_page = 10
    total = Profile.count("id", :conditions=>["profile_type_id = ?", 'ce5c2320-4131-11dc-b432-009096fa4c28'], :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
    begin
      puts "Processing #{offset+1} - #{(offset+per_page)} of approx #{total}"
      profiles = Profile.find(:all, :conditions=>["profile_type_id = ?", 'ce5c2320-4131-11dc-b432-009096fa4c28'], :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
      profiles.each do |profile|
        # generate the profile's private name
        execute "UPDATE profiles SET private_display_name = '#{profile.generate_private_display_name}' where id = '#{profile.id}'"
      end
      offset += per_page
    end while profiles.length > 0


    # for buyers, assign the type (e.g. Single Family Home Buyer)
    say "Updating buyer profiles"

    offset = 0
    per_page = 10
    total = Profile.count("id", :conditions=>["profile_type_id = ?", 'ce5c2320-4131-11dc-b431-009096fa4c28'], :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
    begin
      puts "Processing #{offset+1} - #{(offset+per_page)} of approx #{total}"
      profiles = Profile.find(:all, :conditions=>["profile_type_id = ?", 'ce5c2320-4131-11dc-b431-009096fa4c28'], :order=>"created_at ASC", :offset=>offset, :limit=>per_page)
      profiles.each do |profile|
        # generate the profile's private name
        execute "UPDATE profiles SET private_display_name = '#{profile.generate_private_display_name}' where id = '#{profile.id}'"
      end
      offset += per_page
    end while profiles.length > 0


    #execute "UPDATE profiles SET private_display_name = name where profile_type = 'ce5c2320-4131-11dc-b431-009096fa4c28'"
  end

  def self.down
    # nothing to undo
  end
end
