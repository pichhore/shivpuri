class UpdateFieldProfileDeleteReason < ActiveRecord::Migration
  def self.up
   exists = ProfileDeleteReason.table_exists? rescue false
    if exists
      transaction do
        puts "Update 'Bought through Dwellgo' to 'Bought through REIMatcher'   from profile_delete_reasons "
        # Owner profile reasons
        execute "update profile_delete_reasons set name='Bought through REIMatcher' where id = 'bought_dwellgo' "
      end
    end
  end

  def self.down
   exists = ProfileDeleteReason.table_exists? rescue false
    if exists
      transaction do
        puts "Update 'Bought through REIMatcher' to 'Bought through Dwellgo'   from profile_delete_reasons "
        # Owner profile reasons
        execute "update profile_delete_reasons set name='Bought through Dwellgo' where id = 'bought_dwellgo' "
      end
    end
  end
end
