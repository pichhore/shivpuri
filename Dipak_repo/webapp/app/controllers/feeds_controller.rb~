class FeedsController < ApplicationController
 
  before_filter :login_required, :except=>[:show_snippet]
  CACHE_EXPIRATION = (RAILS_ENV == "staging") ? 60 : 15*60
  
  def show
    @profiles = current_user.profiles.find(:all, :order=>"created_at DESC")
    @user = current_user
    @feed = FeedsController.get_feed(params)
    @community_stats = CommunityStats.new
    @community_stats.fetch_stats
  end
  
  # :link_remote -> link directly to the post instead of displaying the description on our page
  # :feed_title -> replace the default feed title with this one
  def show_snippet
    @feed = FeedsController.get_feed(params)
    if @feed.nil?
      render :text=>""
      return
    end
    @number_to_show = params[:number_to_show] || 4
    @feed.title = params[:feed_title] if params[:feed_title]
    @link_remote = params[:link_remote]
    render :partial=>(params[:template] || "feed_snippet")
  end
  
  def FeedsController.get_feed(params)
    $feed_cache = {} if $feed_cache.nil?
    $feed_cache_expires = {} if $feed_cache_expires.nil?
    
    feed_url = params[:url] || "http://dwellgo.com/blog/pipe_1.xml"
    if $feed_cache_expires[feed_url].nil? or $feed_cache_expires[feed_url] < Time.now
      begin
        feed = FeedTools::Feed.open(feed_url)
        feed.id = params[:id]
        $feed_cache[feed_url] = feed
        $feed_cache_expires[feed_url]= Time.now + CACHE_EXPIRATION
      rescue Exception => e
        ExceptionNotifier.deliver_exception_notification( e,self, request, params)
        puts "Error retrieving feed #{e}"
      end
    else
      feed = $feed_cache[feed_url]
    end
    return feed
  end
end
