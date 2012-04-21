class AddColumnSqueezePageOptIns < ActiveRecord::Migration
  def self.up
	   add_column :squeeze_page_opt_ins, :mail_number, :integer, :default=>0
  end

  def self.down
	   remove_column :squeeze_page_opt_ins, :mail_number
  end
end
