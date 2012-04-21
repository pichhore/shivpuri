class FeedItemController < ApplicationController
  before_filter :login_required
  def show
    @profiles = current_user.profiles.find(:all, :order=>"created_at DESC")
    @user = current_user
    @feed = FeedsController.get_feed(params)
    if ! @feed.nil?
      for item in @feed.items
        if item.id == params[:id]
          @feed_item = item
          break
        end
      end
    end
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end
end
