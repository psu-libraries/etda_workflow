# frozen_string_literal: true

module ApplicationHelper
  # Return the set of css classes that should be associated with this page
  def page_classes
    return '' if controller_name.nil? || action_name.nil?
    classes = []
    classes << controller_name.parameterize
    classes << controller_name.singularize.parameterize
    classes << action_name.parameterize
    classes << "maintain" if %w[new edit create update].include?(action_name)
    classes << current_partner.id
    classes.join(" ")
  end

  def invention_disclosure_number(submission)
    return '' unless submission.invention_disclosures.present?
    submission.invention_disclosures.first.id_number
  end

  def even_odd(row_count)
    @row_count = row_count + 1
    return 'odd' unless (row_count - 1).even?
    ''
  end

  def render_conditional_links
    if Author.current.blank?
      render partial: 'shared/ask_link'
    elsif request.path.start_with? '/admin'
      render partial: 'shared/admin_support_link'
    end
  end

  def fingerprinted_asset(name)
    "#{name}-#{ASSET_FINGERPRINT}"
  end
end
