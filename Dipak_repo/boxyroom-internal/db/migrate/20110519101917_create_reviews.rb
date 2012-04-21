class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.string :title
      t.text :review_text
      t.date :rental_from
      t.date :rental_to
      t.references :application
      t.references :property

      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
