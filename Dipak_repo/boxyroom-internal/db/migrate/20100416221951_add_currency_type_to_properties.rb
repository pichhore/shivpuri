class AddCurrencyTypeToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :currency_type, :string
    Property.all.each do |t|
      t.currency_type = "SGD"
      t.save(false)
    end
  end

  def self.down
    remove_column :properties, :currency_type
  end
end
