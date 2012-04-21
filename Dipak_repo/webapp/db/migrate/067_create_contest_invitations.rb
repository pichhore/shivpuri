class CreateContestInvitations < ActiveRecord::Migration
  def self.up
    exists = ContestInvitation.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table contest_invitations..."
        create_table :contest_invitations, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :from_name, :string
          t.column :from_email, :string
          t.column :to_name, :string
          t.column :to_email, :string
          t.column :campaign_code, :string
          t.column :first_visited_url, :string
          t.column :created_at, :datetime, :null => false
          t.column :accepted_at, :datetime
        end

        puts "Setting primary key"
        execute "ALTER TABLE contest_invitations ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ContestInvitation.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table contest_invitations..."
        drop_table :contest_invitations
      end
    end
  end
end
