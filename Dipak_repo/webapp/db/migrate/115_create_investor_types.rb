class CreateInvestorTypes < ActiveRecord::Migration
  def self.up
    create_table :investor_types do |t|
      t.string :user_id
      t.string :investor_type

      t.timestamps
    end
  end

  def self.down
    drop_table :investor_types
  end
end
