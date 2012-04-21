class CreateActivityCategories < ActiveRecord::Migration
  def self.up
    exists = ActivityCategory.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table activity_categories..."
        create_table :activity_categories, :id => false do |t|
          t.column :id, :string, :limit => 36, :null => false
          t.column :name, :string
        end

        puts "Setting primary key"
        execute "ALTER TABLE activity_categories ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = ActivityCategory.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table activity_categories..."
        drop_table :activity_categories
      end
    end
  end
end
