class ConvertAdsToUseTargetPage < ActiveRecord::Migration
  def self.up
    # target pages:
    # preview_buyers, preview_owners, dashboard_buyer, dashboard_owner, view_buyer, view_owner, mydwellgo

    # manana
    execute "UPDATE ads set target_page = 'mydwellgo' where name = 'manana'"
    Ad.create!({ :name=>"manana", :target_page=>"preview_buyers", :height=>"150", :width=>"240", :link=>"http://www.mananafunding.com", :image_path=>"/images/ads/manana-bannerad.jpg"})

    # homefixers
    execute "UPDATE ads set target_page = 'preview_owners' where name = 'homefixers'"
    Ad.create!({ :name=>"homefixers", :target_page=>"view_owner", :height=>"150", :width=>"240", :link=>"http://www.homefixers.com", :image_path=>"/images/ads/homefixers-bannerad.jpg"})

    # arredondo
    execute "UPDATE ads set target_page = 'dashboard_owner' where name = 'arredondo'"

    # gambrell
    execute "UPDATE ads set target_page = 'dashboard_buyer' where name = 'gambrell'"
    Ad.create!({ :name=>"gambrell", :target_page=>"view_buyer", :height=>"150", :width=>"240", :link=>"http://www.leighshomes.com", :image_path=>"/images/ads/gambrell.jpg"})
  end

  def self.down
  end
end
