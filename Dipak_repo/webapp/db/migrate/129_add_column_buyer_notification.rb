class AddColumnBuyerNotification < ActiveRecord::Migration
  def self.up
	   add_column :buyer_notifications, :trust_responder_series, :boolean, :default=>true
  end

  def self.down
	  remove_column :buyer_notifications, :trust_responder_series
  end
end
