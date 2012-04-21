class AddPartnerAccountIdToTestimonials < ActiveRecord::Migration
  def self.up
    add_column :testimonials, :partner_account_id, :integer, :null => false, :references => nil
  end

  def self.down
    remove_column :testimonials, :partner_account_id
  end
end
