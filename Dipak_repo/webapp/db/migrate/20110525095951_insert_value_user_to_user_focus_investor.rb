class InsertValueUserToUserFocusInvestor < ActiveRecord::Migration
  def self.up
    @user = User.find(:all)
    logger=Logger.new("#{RAILS_ROOT}/log/user_list_of_investor_focus.log")
    @user.each do |user|
          UserFocusInvestor.create(:user_id =>user.id, :is_longterm_hold =>true) if user.investor_focus == "Longterm Hold (Landlord)"
          UserFocusInvestor.create(:user_id =>user.id, :is_fix_and_flip =>true) if user.investor_focus == "Fix & Flip (Rehabber)"
          UserFocusInvestor.create(:user_id =>user.id, :is_lines_and_notes =>true) if user.investor_focus == "Liens & Notes"
          UserFocusInvestor.create(:user_id =>user.id, :is_wholesale =>true) if user.investor_focus == "Wholesale "
          logger.info " Changing Investor focus of  #{user.first_name}#{user.last_name}--#{user.email}---#{user.investor_focus} "
    end
  end

  def self.down
  end
end
