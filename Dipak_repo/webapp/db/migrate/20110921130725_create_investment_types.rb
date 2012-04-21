class CreateInvestmentTypes < ActiveRecord::Migration
  def self.up
    exists = InvestmentType.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table investment_types..."
        create_table :investment_types do |t|
          t.column :code, :string, :null => false
          t.column :name, :string, :null => false
       end
      end
    end
  end

  def self.down
    exists = InvestmentType.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table investment_types..."
        drop_table :investment_types
      end
    end
  end
end
