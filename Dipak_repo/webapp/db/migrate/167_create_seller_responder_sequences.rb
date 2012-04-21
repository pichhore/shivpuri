class CreateSellerResponderSequences < ActiveRecord::Migration
  def self.up
    create_table :seller_responder_sequences ,:id => false do |t|
       t.string :id, :limit => 36, :null => false
      t.string :sequence_name
      t.integer :interval
      t.string :sequence_type

      t.timestamps
    end
     puts "Setting primary key"
     execute "ALTER TABLE seller_responder_sequences ADD PRIMARY KEY (id)"
  end

  def self.down
    drop_table :seller_responder_sequences
  end
end