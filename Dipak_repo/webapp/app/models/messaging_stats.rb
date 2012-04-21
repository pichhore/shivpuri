class MessagingStats

  FIELDS = [:private_message_count]
  create_attrs FIELDS

  def fetch_stats
    self.private_message_count = "#{ProfileMessage.count(:conditions=>['created_at <= now() and created_at >= DATE_SUB(now(),INTERVAL 24 HOUR)'])}"
  end
end
