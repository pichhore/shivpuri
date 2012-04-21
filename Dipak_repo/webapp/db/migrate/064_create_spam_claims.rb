class CreateSpamClaims < ActiveRecord::Migration
  def self.up
    create_table :spam_claims do |t|
      t.column :claim_type, :string
      t.column :claim_id, :string, :references=>nil
      t.column :created_by_user_id, :string, :references=>nil
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :spam_claims
  end
end
