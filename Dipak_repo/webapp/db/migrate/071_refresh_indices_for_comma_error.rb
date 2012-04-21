class RefreshIndicesForCommaError < ActiveRecord::Migration
  def self.up
    ProfileFieldEngineIndex.refresh_indices
  end

  def self.down
    # nothing to do
  end
end
