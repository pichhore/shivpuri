class InsertValuesInInvestmentTypes < ActiveRecord::Migration
  def self.up
    execute("insert into investment_types values(1,'OF','Owner Finance')");
    execute("insert into investment_types values(2,'WS','Wholesale')");
    execute("insert into investment_types values(3,'WSOF','Wholesale And Owner Finance')");
  end

  def self.down
  end
end
