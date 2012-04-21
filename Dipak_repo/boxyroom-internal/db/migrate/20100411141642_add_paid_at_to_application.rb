class AddPaidAtToApplication < ActiveRecord::Migration
  def self.up
    add_column :applications, :paid_at, :datetime

    Application.all.each do |a|
      a.paid_at = Time.now
      a.save
    end
  end

  def self.down
    remove_column :applications, :paid_at
  end
end
