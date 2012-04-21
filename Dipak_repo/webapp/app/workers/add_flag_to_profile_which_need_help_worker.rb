class AddFlagToProfileWhichNeedHelpWorker
  @queue = :add_flag_to_profile_that_need_help
  def self.perform
    Profile.add_flag_for_profile_which_need_help
  end 
end
