class RefreshProfileFieldEngineIndicesForPrivacyField < ActiveRecord::Migration
  def self.up
    ProfileFieldEngineIndex.refresh_indices_old
  end

  def self.down
    # nothing to do
  end
end
