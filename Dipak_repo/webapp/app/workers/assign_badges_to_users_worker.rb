class AssignBadgesToUsersWorker
  @queue = :assign_badge_to_the_users
    def self.perform(limit,offset)
      BadgeUser.assign_badges_to_users(limit,offset)
    end 
end
