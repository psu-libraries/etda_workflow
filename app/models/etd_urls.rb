class EtdUrls
  def explore
    return "http://" + I18n.t("#{current_partner.id}.partner.url_slug") + ".localhost:3000/" if Rails.env.test?

    explore_url
  end

  def popup
    return "alert('Millennium Scholars Explore Coming Soon'); return false;" if Partner.current.milsch?

    ''
  end

  private

  def explore_url
    explore_str = "https://" + I18n.t("#{current_partner.id}.partner.url_slug") + "#{stage_server}.libraries.psu.edu/"
    explore_str
  end

  def stage_server
    return '' if Rails.application.secrets.stage.blank?

    # qa and stage are explore-qa and explore-stage
    "-explore-#{Rails.application.secrets.stage}"
  end
end
