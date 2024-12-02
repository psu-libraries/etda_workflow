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
      if ENV['EXPLORE_HOST']
        "https://#{ENV['EXPLORE_HOST']}"
      else
        "https://#{EtdaUtilities::Hosts.new.explore_host(current_partner.id, ENV['RAILS_ENV'])}"
      end
    end

    def workflow_url
      if ENV['WORKFLOW_HOST']
        "https://#{ENV['WORKFLOW_HOST']}"
      else
        "https://#{EtdaUtilities::Hosts.new.workflow_submit_host(current_partner.id, ENV['RAILS_ENV'])}"
      end
    end
end
