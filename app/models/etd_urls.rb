class EtdUrls
  def explore
    return "http://#{I18n.t("#{current_partner.id}.partner.url_slug")}.localhost:3000" if Rails.env.test?

    explore_url
  end

  def workflow
    return "#{workflow_url}.localhost:3000" if Rails.env.test?

    workflow_url
  end

  private

    def explore_url
      # Prefer an explicit ENV override when present (useful for deploy-time host overrides)
      # Fall back to building the host from EtdaUtilities when no ENV override is set
      host = ENV['EXPLORE_HOST'] || EtdaUtilities::Hosts.new.explore_host(current_partner.id, ENV['RAILS_ENV'])

      # In production only: remove a trailing '-main' (branch suffix) if supplied by ENV
      host = host.to_s.delete_suffix('-main') if Rails.env.production?

      "https://#{host}"
    end

    def workflow_url
      # Prefer an explicit ENV override when present (useful for deploy-time host overrides)
      # Fall back to building the host from EtdaUtilities when no ENV override is set
      host = ENV['WORKFLOW_HOST'] || EtdaUtilities::Hosts.new.workflow_submit_host(current_partner.id, ENV['RAILS_ENV'])

      # In production only: remove a trailing '-main' (branch suffix) if supplied by ENV
      host = host.to_s.delete_suffix('-main') if Rails.env.production?

      "https://#{host}"
    end
end
