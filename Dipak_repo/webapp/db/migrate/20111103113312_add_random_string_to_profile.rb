class AddRandomStringToProfile < ActiveRecord::Migration
  #require 'securerandom'

  def self.up
    add_column :profiles, :random_string, :string
    Profile.reset_column_information
    cnt =  Profile.find_all_by_profile_type_id('ce5c2320-4131-11dc-b432-009096fa4c28').size
    a = (0..999999).to_a.sort_by { rand }
    a = a.slice(1..cnt).map{|n| n.to_s.rjust(6, '0')}
    i = 0
    Profile.find_all_by_profile_type_id('ce5c2320-4131-11dc-b432-009096fa4c28').each do |f|
     #flag = true
     #while(!flag.nil?)
       #rand_str = SecureRandom.hex(4)
       #flag = Profile.find_by_random_string(rand_str)
     #end
     Profile.connection.execute("Update profiles set random_string=\"#{a[i]}\" where id=\"#{f.id}\";")
     i += 1
     end
  end

  def self.down
    remove_column :profiles, :random_string
  end
end
