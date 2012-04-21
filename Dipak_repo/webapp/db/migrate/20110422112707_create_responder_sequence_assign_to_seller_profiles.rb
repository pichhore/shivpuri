class CreateResponderSequenceAssignToSellerProfiles < ActiveRecord::Migration
  def self.up
    create_table :responder_sequence_assign_to_seller_profiles do |t|
      t.string :seller_responder_sequence_id, :references => :seller_responder_sequences
      t.string :seller_profile_id, :limit => 36,  :references => :seller_profiles
      t.integer :mail_number
      t.timestamps
    end
  end

  def self.down
    drop_table :responder_sequence_assign_to_seller_profiles
  end
end
