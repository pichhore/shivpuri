class CreateSellerFinancialInfos < ActiveRecord::Migration

  def self.up
    exists = SellerFinancialInfo.table_exists? rescue false
    if !exists
      transaction do
        puts "Adding table seller_financial_infos..."
        create_table "seller_financial_infos", :id => false do |t|
          t.column :id,                        :string, :limit => 36, :null => false
          t.column :seller_property_profile_id,:string, :limit => 36, :null => false, :references => :seller_property_profiles
          t.column :financial_loan_number,     :string
          t.column :origination_date,          :string
          t.column :original_loan_payment,     :string
          t.column :monthly_payment,           :string
          t.column :interest_rate,             :string
          t.column :estimated_balance,         :string
          t.column :loan_type,                 :string
          t.column :loan_term,                 :string
          t.column :last_payment_date,         :string
          t.column :back_payment,              :string
          t.column :lender,                    :string
          t.column :loan_number,               :string
          t.column :other_financial_note,      :text
          t.timestamps
        end
        puts "Setting primary key"
        execute "ALTER TABLE seller_financial_infos ADD PRIMARY KEY (id)"
      end
    end
  end

  def self.down
    exists = SellerFinancialInfo.table_exists? rescue false
    if exists
      transaction do
        puts "Dropping table seller_financial_infos..."
        drop_table :seller_financial_infos
      end
    end
  end
end
