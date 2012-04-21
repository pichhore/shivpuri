class ProcessUsersToAssignBadgesWorker
  @queue = :process_users_to_assign_badge
    def self.perform
      BadgeUser.process_users_to_assign_badges
    end 
end
