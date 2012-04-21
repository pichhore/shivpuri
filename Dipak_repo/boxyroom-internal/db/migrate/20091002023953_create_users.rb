class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string    :first_name
      t.string    :last_name
      t.date      :birth_date
      t.string    :occupation
      t.string    :profile_image_url
      t.string    :about

      t.string    :email,                 :null => false
      t.string    :crypted_password,      :null => false
      t.string    :password_salt,         :null => false
      t.string    :level # Tenant, Landlord, Administrator
      t.string    :persistence_token,     :null => false
      t.string    :perishable_token,      :null => false
      t.boolean   :active,                :null => false, :default => false

      t.integer   :failed_login_count,    :null => false, :default => 0
      t.string    :current_login_ip
      t.string    :last_login_ip

      t.datetime  :current_login_at
      t.datetime  :last_login_at

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
