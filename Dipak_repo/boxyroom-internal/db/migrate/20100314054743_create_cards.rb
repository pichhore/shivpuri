class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.string :first_name
      t.string :last_name
      t.string :relationship
      t.string :email
      t.string :phone_no
      t.string :mobile_no
      t.string :fax_no

      t.timestamps
    end
  end

  def self.down
    drop_table :cards
  end
end
