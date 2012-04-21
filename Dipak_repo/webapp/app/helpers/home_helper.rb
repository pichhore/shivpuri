module HomeHelper

  def display_feeds(feed)
    if feed.activity_id == 1
      return "<p><strong><font style='color:#5CC003;'> #{feed.user.first_name.humanize}</font> added <font style='font-weight: normal;'>a New Buyer Profile in</font>  #{feed.territory.reim_name.humanize}</strong></p>"
    end
    if feed.activity_id == 2
      return "<p><strong><font style='color:#5CC003;'> #{feed.user.first_name.humanize}</font> added <font style='font-weight: normal;'>a home for sale in</font>  #{feed.territory.reim_name.humanize}</strong></p>"
    end
    if feed.activity_id == 3
      return "<p><strong> <font style='color:#5CC003;'>#{feed.user.first_name.humanize}</font> sold <font style='font-weight: normal;'>a property in</font>  #{feed.territory.reim_name.humanize}</strong></p>"
    end
    if feed.activity_id == 4
      return "<p><strong> <font style='color:#5CC003;'>#{feed.user.first_name.humanize}</font> bought <font style='font-weight: normal;'>a property in</font>  #{feed.territory.reim_name.humanize}</strong></p>"
    end
    if feed.activity_id == 5
      return "<p><strong> <font style='color:#5CC003;'>#{feed.user.first_name.humanize}</font> is talking with <font style='font-weight: normal;'>a Seller in</font>  #{feed.territory.reim_name.humanize}</strong></p>"
    end
  end
end
