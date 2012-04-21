class AddFieldBusinessTravel < ActiveRecord::Migration
  def self.up
    add_column :reviews, :review_title_business, :string
    add_column :reviews, :review_text_business, :string
    add_column :reviews, :review_title_travel, :string
    add_column :reviews, :review_text_travel, :string
  end

  def self.down
    remove_column :reviews, :review_title_business
    remove_column :reviews, :review_text_business
    remove_column :reviews, :review_title_travel
    remove_column :reviews, :review_text_travel
  end
end
