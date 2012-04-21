class PreloadProfilesWithDefaultThumbnailUrls < ActiveRecord::Migration
  def self.up
    Profile.refresh_thumbnails
  end

  def self.down
    # nothing to undo
  end
end
