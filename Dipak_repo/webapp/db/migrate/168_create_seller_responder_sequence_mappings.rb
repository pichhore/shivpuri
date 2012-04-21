class CreateSellerResponderSequenceMappings < ActiveRecord::Migration
  def self.up
    create_table :seller_responder_sequence_mappings,:id => false do |t|
       t.string :id, :limit => 36, :null => false
      t.integer :email_number
      t.string :seller_profile_id , :limit => 36,  :references => :seller_profiles
      t.string :seller_responder_sequence_id,  :limit => 36, :references => :seller_responder_sequences
      t.timestamps
    end
    puts "Setting primary key"
    execute "ALTER TABLE seller_responder_sequence_mappings ADD PRIMARY KEY (id)"
  end

  def self.down
    drop_table :seller_responder_sequence_mappings
  end
end
