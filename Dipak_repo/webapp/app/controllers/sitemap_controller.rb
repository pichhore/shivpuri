class SitemapController < ApplicationController
  def sitemap
    @profiles = Profile.find_public_property_profiles
    render :layout=>false
  end

  def properties
    @profiles = Profile.find_public_property_profiles
  end
end
