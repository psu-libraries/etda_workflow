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

  def author_nav_active?(nav_name)
    case nav_name
    when 'submissions'
       'active' if not_published_page || controller_name == 'committee_members' || controller_name == 'submission_format_review'
    when 'author'
       'active' if controller_name == 'authors' && action_name != 'technical_tips'
    when 'tips'
       'active' if action_name == 'technical_tips'
    when 'published'
      'active' if action_name == 'published_submissions_index'
    else
       ''
    end
  end

  def not_published_page
    controller_name == 'submissions' && action_name != 'published_submissions_index'
  end

  def admin_nav_active?(nav_name)
    return 'active' if controller_name == nav_name

    ''
  end

  def invention_disclosure_number(submission)
    return '' if submission.invention_disclosures.blank?

    submission.invention_disclosures.first.id_number
  end

  def even_odd(row_count)
    @row_count = row_count + 1
    return 'odd' unless (row_count - 1).even?

    ''
  end

  def render_conditional_links
    if current_author.blank?
      render partial: 'shared/ask_link'
    elsif session[:user_role] == 'admin'
      render partial: 'shared/admin_support_link'
    end
  end

  def fingerprinted_asset(name)
    "#{name}-#{ASSET_FINGERPRINT}"
  end

  def current_version_number
    return '' if VERSION_NUMBER.empty?

    current_number = VERSION_NUMBER
    "Version: #{current_number.strip}"
  end

  def confidential_tag_helper(author)
    return '' unless author.confidential_hold?

    " <span class='confidential-alert xxs' aria-hidden='true' data-toggle='tooltip' data-placement='top' title='confidential hold'><span class='fa fa-warning'></span></span><span class='sr-only'>#{author.first_name} #{author.last_name} has a confidential hold</span>"
  end
end
