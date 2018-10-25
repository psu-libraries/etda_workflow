class EtdUrls
  def explore
  # After release, remove '-explore' bc the URL will change to etda.libraries, etda-qa.libraries, etc.
  return "http://" + I18n.t("#{current_partner.id}.partner.url_slug") + "-explore.localhost:3000" if Rails.env.test?

  explore_url
  end

  private

  # After release, remove '-explore' bc the URL will change to etda.libraries, etda-qa.libraries, etc.
  def explore_url
     explore_str = "https://" + I18n.t("#{current_partner.id}.partner.url_slug") + "-explore#{stage_server}.libraries.psu.edu"
     explore_str
  end

  def stage_server
    return '' if Rails.application.secrets.stage.blank?

    "-#{Rails.application.secrets.stage}"
  end
end
