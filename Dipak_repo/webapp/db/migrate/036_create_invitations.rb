class CreateInvitations < ActiveRecord::Migration
  def self.up
    exists = Invitation.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table invitations..."
        create_table :invitations, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :user_id, :string, :limit => 36, :null => false
          t.column :to_email, :string, :null => false
          t.column :to_first_name, :string
          t.column :to_last_name, :string
          t.column :invitation_message, :text, :null => false
          t.column :created_at, :datetime, :null => false
          t.column :accepted_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE invitations ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = Invitation.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table invitations..."
        drop_table :invitations
      end
    end
  end
end
