class AddDealTermsVideoTourAndEmbedvideoToProfileFieldEngineIndices < ActiveRecord::Migration
  def self.up
    add_column :profile_field_engine_indices, :deal_terms, :text
    add_column :profile_field_engine_indices, :video_tour, :string
    add_column :profile_field_engine_indices, :embed_video,:text
  end

  def self.down
    remove_column :profile_field_engine_indices, :deal_terms
    remove_column :profile_field_engine_indices, :video_tour
    remove_column :profile_field_engine_indices, :embed_video    
  end
end
