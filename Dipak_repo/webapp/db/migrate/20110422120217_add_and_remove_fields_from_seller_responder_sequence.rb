class AddAndRemoveFieldsFromSellerResponderSequence < ActiveRecord::Migration
  def self.up
    add_column :seller_responder_sequences,             :user_id,         :string
    add_column :seller_responder_sequences,             :active,          :boolean
    add_column :seller_responder_sequence_mappings,     :email_subject,   :text
    add_column :seller_responder_sequence_mappings,     :email_body,      :text
    remove_column :seller_responder_sequence_mappings,  :seller_profile_id
  end

  def self.down
    remove_column :seller_responder_sequences,             :user_id
    remove_column :seller_responder_sequences,             :active
    remove_column :seller_responder_sequence_mappings,     :email_subject
    remove_column :seller_responder_sequence_mappings,     :email_body
    add_column    :seller_responder_sequence_mappings,     :seller_profile_id, :string, :limit => 36,  :references => :seller_profiles
  end
end
