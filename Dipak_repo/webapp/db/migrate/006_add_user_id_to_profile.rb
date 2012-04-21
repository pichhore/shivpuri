class AddUserIdToProfile < ActiveRecord::Migration
  def self.up
    Profile.transaction do
      if !Profile.columns.collect { |column| column.name}.include?("user_id")
        puts "Adding the 'user_id' column to profiles..."
        add_column :profiles, :user_id, :string, :limit=>36
      end
      puts "Adding FK constraint for 'user_id' column to profiles..."
      execute "update profiles set user_id = null where user_id is not null"
      execute "alter table profiles add FOREIGN KEY (user_id) REFERENCES users(id)"
    end
  end

  def self.down
    # column already existed - nothing to revert
  end
end
