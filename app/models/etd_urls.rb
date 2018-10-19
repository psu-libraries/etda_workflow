class EtdUrls
  def explore
    return "http://" + I18n.t("#{current_partner.id}.partner.url_slug") + "-explore.localhost:3000" if Rails.env.test?

    explore_url
  end

  private

  def explore_url
     explore_str = "https://" + I18n.t("#{current_partner.id}.partner.url_slug") + "-explore#{stage_server}.libraries.psu.edu"
     explore_str
  end

  def stage_server
    return '' if Rails.application.secrets.stage.nil?

    "-#{Rails.application.secrets.stage}"
  end
end
