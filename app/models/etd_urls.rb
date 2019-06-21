class EtdUrls
  def explore
    return "http://" + I18n.t("#{current_partner.id}.partner.url_slug") + ".localhost:3000/" if Rails.env.test?

    explore_url
  end

  def workflow
    return workflow_url + ".localhost:3000/" if Rails.env.test?

    workflow_url
  end

  def popup
    return "alert('Millennium Scholars Explore Coming Soon'); return false;" if Partner.current.milsch?

    ''
  end

  private

  def explore_url
    explore_str = "https://" + EtdaUtilities::Hosts.new.explore_host(current_partner.id, Rails.application.secrets.stage)
    explore_str
  end

  def workflow_url
    workflow_str = "https://" + EtdaUtilities::Hosts.new.workflow_submit_host(current_partner.id, Rails.application.secrets.stage)
    workflow_str
  end
end
