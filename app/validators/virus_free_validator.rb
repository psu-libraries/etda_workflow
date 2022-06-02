class VirusFreeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless has_a_virus?(value)

    record.errors.add(attribute, options[:message] || :virus_free)
  end

  private

    #  def has_a_virus?(value)
    #    @logger ||= Logger.new(Rails.root.join('log', 'clam_scan.log'))
    #    value.present? && !VirusScanner.scan(location: value.url).tap{|scan_response| @logger.info scan_
    #    response.inspect }.safe?
    #  end

    def has_a_virus?(value)
      value.present? && !VirusScanner.safe?(value.url)
    end
end
