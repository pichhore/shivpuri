class AdsController < ApplicationController
  before_filter :load_ad, :only=>[:show]

  # ignoring other RESTful methods for now
  def show
    user_id = current_user.id if logged_in?
    profile_id = @profile.id if @profile
    AdClick.create!({ :ad_id=>@ad.id, :user_id=>user_id, :profile_id=>profile_id})

    redirect_to @ad.link
  end
end
