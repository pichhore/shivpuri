module Admin::AdminAdsHelper

  def created_at_column(record)
    record.created_at.nil? ? record.created_at : record.created_at.strftime("%m/%d/%Y %I:%M %p")
  end 
end
