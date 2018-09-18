class SolrLog
  def self.info(message = nil)
    return if message.nil?

    @solr_log ||= Logger.new("#{Rails.root}/log/solr_#{Rails.env}.log")
    display_message = message.to_s unless message.nil?
    @solr_log.info(display_message)
  end
end
