class CreateTrustResponderMailSeries < ActiveRecord::Migration
  def self.up
    create_table :trust_responder_mail_series do |t|
      t.integer :buyer_notification_id
      t.string :trust_responder_summary_type
      t.text :email_body
      t.text :email_subject
      t.timestamps
    end
  end

  def self.down
    drop_table :trust_responder_mail_series
  end
end
