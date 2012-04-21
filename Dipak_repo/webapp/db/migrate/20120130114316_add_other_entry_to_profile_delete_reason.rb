class AddOtherEntryToProfileDeleteReason < ActiveRecord::Migration
  def self.up
    buyer = ProfileType.find_by_name("buyer")
    owner = ProfileType.find_by_name("owner")
    execute "INSERT into profile_delete_reasons (id, profile_type_id, name, created_at) values ('other_buyer','#{buyer.id}', 'Other',now())"
    execute "INSERT into profile_delete_reasons (id, profile_type_id, name, created_at) values ('other_owner','#{owner.id}', 'Other',now())"
  end

  def self.down
  end
end
