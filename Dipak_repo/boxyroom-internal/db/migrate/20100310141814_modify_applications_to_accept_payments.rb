class ModifyApplicationsToAcceptPayments < ActiveRecord::Migration
  def self.up
    add_column :applications, :first_name, :string
    add_column :applications, :last_name, :string

    add_column :applications, :ip_address, :string

    add_column :applications, :card_type, :string
    add_column :applications, :card_expires_on, :date

    add_column :applications, :status, :string # this will be used by aasm

    Application.all.each do |a|
      a.status = a.state
      a.save!
    end

    remove_column :applications, :state
  end

  def self.down
    add_column :applications, :state, :string
    
    Application.all.each do |a|
      a.state = a.status
      a.save!
    end

    remove_column :applications, :first_name
    remove_column :applications, :last_name

    remove_column :applications, :ip_address

    remove_column :applications, :card_type
    remove_column :applications, :card_expires_on

    remove_column :applications, :address
    remove_column :applications, :city
    remove_column :applications, :status
    remove_column :applications, :country
    remove_column :applications, :zip
  end
end
