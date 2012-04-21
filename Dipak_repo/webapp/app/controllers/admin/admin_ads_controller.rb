class Admin::AdminAdsController < Admin::AdminController
  active_scaffold :ad do |config|
    list.columns = [:target_page, :name, :link, :image_path, :width, :height, :created_at]
    #list.sorting = {:target_page => 'ASC'}
    config.columns = [:target_page, :name, :link, :image_path, :width, :height, :created_at]
    columns[:image_path].description = "full path - e.g. http://reimatcher.com.s3.amazonaws.com/Affiliate-Sales/black-box-social-media/Sm-in-7-min-V1.jpg"
    columns[:link].description = "Full URL - e.g. http://www.dwellgo.com"
    columns[:name].description = "A simple name, no spaces, to reference the ad by when we want to reference a specific ad in a specific location of the site. Reports are sorted by this field for easier reporting."
    columns[:target_page].description = "The page that the ad should appear, from the following list: <strong>preview_buyers, preview_owners, dashboard_buyer, dashboard_owner, view_buyer, view_owner, mydwellgo</strong><br/><strong>(Note: enter only 1 target page - create multiple Ad entries for ads that should appear on multiple pages)</strong>"
    #config.actions.exclude :create, :delete
  end
end

