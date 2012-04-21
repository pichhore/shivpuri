class MergeContactsWithUsersTable < ActiveRecord::Migration
  def self.up
    drop_table :contacts

    add_column :users, :phone_no, :string
    add_column :users, :mobile_no, :string
    add_column :users, :fax_no, :string
  end

  def self.down
    remove_column :users, :phone_no
    remove_column :users, :mobile_no
    remove_column :users, :fax_no

    create_table :contacts do |t|
      t.references :contactable, :polymorphic => true

      t.string :relationship

      t.string :first_name
      t.string :last_name

      t.string :email
      t.string :phone_no
      t.string :mobile_no
      t.string :fax_no

      t.timestamps
    end
  end
end
