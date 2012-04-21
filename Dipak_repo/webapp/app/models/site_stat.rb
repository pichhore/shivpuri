class SiteStat < ActiveRecord::Base
  uses_guid
  belongs_to :site_stat_type

  def self.find_recent(start_date_string, end_date_string)
    return self.find(:all, :conditions=>["DATE(stats_date) <= ? AND DATE(stats_date) >= ?", end_date_string, start_date_string], :order=>"stats_date DESC, site_stat_type_id", :include=>:site_stat_type)
  end
end
