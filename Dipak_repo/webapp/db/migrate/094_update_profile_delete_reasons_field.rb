class UpdateProfileDeleteReasonsField < ActiveRecord::Migration
  def self.up
    exists = ProfileDeleteReason.table_exists? rescue false
    if exists
      transaction do
        puts "Update 'Sold through Dwellgo' to 'Sold through REIMatcher'   from profile_delete_reasons "
        # Owner profile reasons
        execute "update profile_delete_reasons set name='Sold through REIMatcher' where id = 'sold_dwellgo' "
      end
    end
  end

  def self.down
    exists = ProfileDeleteReason.table_exists? rescue false
    if exists
      transaction do
        puts "Update 'Sold through REIMatcher' to 'Sold through Dwellgo'   from profile_delete_reasons "
        # Owner profile reasons
        execute "update profile_delete_reasons set name='Sold through Dwellgo' where id = 'sold_dwellgo' "
      end
    end
  end
end
