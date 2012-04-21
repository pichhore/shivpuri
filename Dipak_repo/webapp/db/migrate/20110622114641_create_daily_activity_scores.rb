class CreateDailyActivityScores < ActiveRecord::Migration
  def self.up
    create_table :daily_activity_scores, :id => false do |t|
      t.column :id, :string, :limit => 36, :null => false
      t.column :user_id, :string, :limit => 36, :references => nil, :null => false
      t.column :created_at, :date
      t.column :score, :float, :default => 0
    end
  end

  def self.down
    drop_table :daily_activity_scores
  end
end