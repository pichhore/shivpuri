class AddToRefundToApplication < ActiveRecord::Migration
  def self.up
    add_column :applications, :to_refund, :boolean

    Application.all.each do |a|
      a.to_refund = false
      a.save
    end
  end

  def self.down
    remove_column :applications, :to_refund
  end
end
