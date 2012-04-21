class CreateUserFocusInvestors < ActiveRecord::Migration
  def self.up
    create_table :user_focus_investors do |t|
      t.string :user_id,:limit => 36, :null => false, :references =>:users
      t.boolean :is_longterm_hold,:default=>false
      t.boolean :is_fix_and_flip,:default=>false
      t.boolean :is_wholesale,:default=>false
      t.boolean :is_lines_and_notes,:default=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :user_focus_investors
  end
end
