class AddSubscriptionColumnToSequeezePageOptIn < ActiveRecord::Migration
  def self.up
      add_column :squeeze_page_opt_ins, :trust_responder_subscription,:boolean,:default=>true
  end

  def self.down
      remove_column :squeeze_page_opt_ins, :trust_responder_subscription
  end
end
