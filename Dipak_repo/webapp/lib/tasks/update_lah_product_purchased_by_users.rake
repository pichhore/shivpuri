namespace :product_purchased do
  desc 'update data for old users'
  task :upadte_lah_product_purchased_by_user => :environment do
    LahProductPurchasedByUser.update_all("product_type = 'monthly'", ["product_ids in (?)", ['7914484', '8233775', '7876355', '8607354', '8978596', '8864500', '8661415', '8694664', '8869733', '8807645', '8899596', '8963150', '121318', '121763', '119368', '119367', '119147', '119146', '120545', '120546', '121373', '120433']])
    LahProductPurchasedByUser.update_all("product_type = 'yearly'", ["product_ids in (?)", ["8285676", "8607368", "7914493", "7914489", "8653884", "121760"]])
    LahProductPurchasedByUser.update_all("product_type = 'bi_weekly'", ["product_ids in (?)", ["8877441"]])
    LahProductPurchasedByUser.update_all("product_type = 'fort_night'", ["product_ids in (?)", ["8694652", "8758494"]])
    LahProductPurchasedByUser.update_all("product_type = 'non_recurring'", ["product_ids not in (?)",['7914484', '8233775', '7876355', '8607354', '8978596', '8864500', '8661415', '8694664', '8869733', '8807645', '8899596', '8963150', '121318', '121763', '119368', '119367', '119147', '119146', '120545', '120546', '121373', '120433',"8285676", "8607368", "7914493", "7914489", "8653884", "121760","8877441","8694652", "8758494"]])
  end
end


