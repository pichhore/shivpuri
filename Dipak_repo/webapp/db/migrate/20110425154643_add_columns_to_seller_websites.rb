class AddColumnsToSellerWebsites < ActiveRecord::Migration
  def self.up
    add_column :seller_websites,:lead_funnel_video_tour,:string
    add_column :seller_websites,:lead_funnel_embed_video,:string
    add_column :seller_websites,:about_us_page_text,:text
    add_column :seller_websites,:lead_funnel_default_video,:boolean
    add_column :seller_websites,:home_page_main_text_2,:string
    rename_column :seller_websites,:embed_video,:home_page_embed_video
    rename_column :seller_websites,:video_tour,:home_page_video_tour
    rename_column :seller_websites,:opening_text,:home_page_main_text_1
    rename_column :seller_websites,:default_video,:home_page_default_video
  end

  def self.down
    remove_column :seller_websites,:lead_funnel_video_tour
    remove_column :seller_websites,:lead_funnel_embed_video
    remove_column :seller_websites,:about_us_page_text
    remove_column :seller_websites,:lead_funnel_default_video
    remove_column :seller_websites,:home_page_main_text_2
    rename_column :seller_websites,:home_page_embed_video,:embed_video
    rename_column :seller_websites,:home_page_video_tour,:video_tour
    rename_column :seller_websites,:home_page_main_text_1,:opening_text
    rename_column :seller_websites,:home_page_default_video,:default_video
  end
      
end
