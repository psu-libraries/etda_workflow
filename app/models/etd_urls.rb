class EtdUrls
  def base
    return I18n.t("#{current_partner.id}.partner.url_slug") + "-explore.localhost:3000" if Rails.env.test?

    ApplicationUrl.current
  end

  def explore
   explore_url
  end

  private

  def explore_url
     return '' if base.nil?

     explore_str = "https://" + I18n.t("#{current_partner.id}.partner.url_slug") + "-explore#{ApplicationUrl.stage}.libraries.psu.edu/"
     explore_str
  end
end
