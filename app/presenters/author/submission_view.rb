class Author::SubmissionView < SimpleDelegator
  require 'delegate'
  # Our submission view should truly pose as the wrapped object,
  # since some Rails helpers will use this for naming conventions.
  delegate :class, to: :__getobj__

  def formatted_program_information
    program_name + ' ' + degree.name + ' - ' + formatted_semester + ' ' + formatted_year
  end

  def delete_link
    if status_behavior.beyond_collecting_format_review_files? || format_review_notes.present?
      ''
    else
      ("<span class='delete-link medium'><a href='" + "/author/submissions/#{id}" + "' class='text-danger' data-method='delete' data-confirm='Permanently delete this submission?' rel='nofollow' >[delete submission<span class='sr-only'>submission '#{title}'</span>]</a></span>").html_safe
    end
  end

  def created_on
    created_at.strftime('%B %-e, %Y')
  end

  def step_one_description
    if status_behavior.beyond_collecting_committee?
      ("Provide program information <a href='" + "/author/submissions/#{id}/program_information" + "' class='medium'>[review <span class='sr-only'>program information for submission '#{title}'</span>]</a>").html_safe
    else
      ("Provide program information <a href='" + "/author/submissions/#{id}/edit" + "' class='medium'>[update <span class='sr-only'>program information for submission '#{title}'</span>]</a>").html_safe
    end
  end

  def step_two_class
    if status_behavior.beyond_collecting_committee?
      'complete'
    else
      'current'
    end
  end

  def step_two_description
    if status_behavior.collecting_committee?
      ("<a href='" + "/author/submissions/#{id}/committee_members/new" + "'>" + step_two_name + "</a>").html_safe
    elsif status_behavior.ok_to_update_committee?
      (step_two_name + "<a href='" + "/author/submissions/#{id}/committee_members/edit" + "' class='medium'>[update <span class='sr-only'>committee for submission '#{title}' </span>]</a>").html_safe
    elsif status_behavior.beyond_collecting_format_review_files? || using_lionpath?
      (step_two_name + "<a href='" + "/author/submissions/#{id}/committee_members" + "' class='medium'>[review <span class='sr-only'>committee for submission '#{title}' </span>]</a>").html_safe
    else
      step_two_name
    end
  end

  def step_two_status
    if status_behavior.beyond_collecting_committee?
      "completed#{formatted_timestamp_of(committee_provided_at)}"
    else
      ''
    end
  end

  def step_two_name
    return 'Provide Committee ' unless using_lionpath?

    'Verify Committee'
  end

  def step_three_class
    if status_behavior.collecting_format_review_files?
      'current'
    elsif status_behavior.beyond_collecting_format_review_files?
      'complete'
    else
      ''
    end
  end

  def step_three_description
    if status_behavior.collecting_format_review_files?
      if status_behavior.collecting_format_review_files_rejected? || format_review_notes.present?
        "Upload Format Review files <a href='/author/submissions/#{id}/format_review/edit' class='medium'>[update <span class='sr-only'>format review files for submission '#{title}' </span>]</a>".html_safe
      else
        "<a href='/author/submissions/#{id}/format_review/edit'>Upload Format Review files</a>".html_safe
      end
    elsif status_behavior.beyond_collecting_format_review_files?
      "Upload Format Review files <a href='/author/submissions/#{id}/format_review' class='medium'>[review <span class='sr-only'>format review files for submission '#{title}' </span>]</a>".html_safe
    else
      'Upload Format Review files'
    end
  end

  def step_three_status
    status = {}
    if status_behavior.beyond_collecting_format_review_files?
      status[:text] = "completed#{formatted_timestamp_of(format_review_files_uploaded_at)}"
      status[:partial_name] = '/author/shared/completed_indicator'
    elsif status_behavior.collecting_format_review_files? && status_behavior.collecting_format_review_files_rejected?
      status[:text] = "rejected#{formatted_timestamp_of(format_review_rejected_at)}"
      status[:partial_name] = '/author/shared/rejected_indicator'
    end
    status
  end

  def step_four_class
    if status_behavior.waiting_for_format_review_response?
      'current'
    elsif status_behavior.beyond_waiting_for_format_review_response?
      'complete'
    else
      ''
    end
  end

  def step_four_status
    status = {}
    if status_behavior.beyond_waiting_for_format_review_response?
      status[:text] = "review completed#{formatted_timestamp_of(format_review_approved_at)}"
      status[:partial_name] = '/author/shared/completed_indicator'
    elsif status_behavior.waiting_for_format_review_response?
      status[:partial_name] = '/author/shared/under_review_indicator'
    end
    status
  end

  def step_five_class
    if status_behavior.collecting_final_submission_files?
      'current'
    elsif status_behavior.beyond_collecting_final_submission_files?
      'complete'
    else
      ''
    end
  end

  def step_five_description
    if status_behavior.collecting_final_submission_files?
      if status_behavior.collecting_final_submission_files_rejected?
        ("Upload Final Submission files <a href=" + "\'/author/submissions/#{id}/final_submission/edit\'" + " class='medium'>[update <span class='sr-only'>final submission files for submission '#{title}' </span>]</a>").html_safe
      else
        ("<a href='" + "/author/submissions/#{id}/final_submission/edit" + "'>Upload Final Submission files</a>").html_safe
      end
    elsif status_behavior.beyond_collecting_final_submission_files? || status_behavior.waiting_for_final_submission_response?
      ("Upload Final Submission files <a href='" + "/author/submissions/#{id}/final_submission" + "' class='medium'>[review <span class='sr-only'>final submission files for submission '#{title}'</span>]</a>").html_safe
    else
      'Upload Final Submission files'
    end
  end

  def step_five_status
    status = {}
    if status_behavior.beyond_collecting_final_submission_files?
      status[:partial_name] = '/author/shared/completed_indicator'
      status[:text] = "completed#{formatted_timestamp_of(final_submission_files_uploaded_at)}"
    elsif status_behavior.collecting_final_submission_files_rejected?
      status[:partial_name] = '/author/shared/rejected_indicator'
      status[:text] = "rejected#{formatted_timestamp_of(final_submission_rejected_at)}"
    end
    status
  end

  def step_six_class
    if status_behavior.waiting_for_committee_review?
      'current'
    elsif status_behavior.beyond_waiting_for_committee_review?
      'complete'
    else
      ''
    end
  end

  def step_six_status
    status = {}
    if status_behavior.waiting_for_committee_review_rejected?
      status[:partial_name] = '/author/shared/rejected_indicator'
    elsif status_behavior.beyond_waiting_for_committee_review?
      # status[:text] = "approved#{formatted_timestamp_of(final_submission_approved_at)}"
      status[:partial_name] = '/author/shared/completed_indicator'
    elsif status_behavior.waiting_for_committee_review?
      status[:partial_name] = '/author/shared/waiting_indicator'
    end
    status
  end

  def step_seven_class
    if status_behavior.waiting_for_final_submission_response?
      'current'
    elsif status_behavior.beyond_waiting_for_final_submission_response?
      'complete'
    else
      ''
    end
  end

  def step_seven_status
    status = {}
    if status_behavior.beyond_waiting_for_final_submission_response?
      status[:text] = "approved#{formatted_timestamp_of(final_submission_approved_at)}"
      status[:partial_name] = '/author/shared/completed_indicator'
    elsif status_behavior.waiting_for_final_submission_response?
      status[:partial_name] = '/author/shared/under_review_indicator'
    end
    status
  end

  def step_eight_class
    if status_behavior.waiting_for_publication_release? || status_behavior.released_for_publication?
      'complete'
    else
      ''
    end
  end

  def step_eight_status
    return '' unless status_behavior.waiting_for_publication_release? || status_behavior.released_for_publication?

    "<div class='step complete final'><strong>#{degree_type.name} Submission is Complete</strong></div>".html_safe
  end

  def step_eight_arrow
    return '<div class="direction glyphicon glyphicon-arrow-down"></div>'.html_safe if status_behavior.waiting_for_publication_release? || status_behavior.released_for_publication?

    ''
  end

  def step_info(num)
    "<span class='sr-only'> step #{num} information</span>".html_safe
  end

  def display_notes?(step_number)
    return display_format_review_notes?(step_number) if [3, 4].include? step_number
    return display_final_submission_notes?(step_number) if [5, 6].include? step_number

    false
  end

  def notes_link(step_number)
    if step_number < 5
      return Rails.application.routes.url_helpers.author_submission_format_review_path(id, anchor: "format-review-notes") unless status_behavior.collecting_format_review_files?

      Rails.application.routes.url_helpers.author_submission_edit_format_review_path(id, anchor: "format-review-notes") else
                                                                                                                                 return Rails.application.routes.url_helpers.author_submission_final_submission_path(id, anchor: "final-submission-notes") unless status_behavior.collecting_final_submission_files?

                                                                                                                                 Rails.application.routes.url_helpers.author_submission_edit_final_submission_path(id, anchor: "final-submission-notes")
    end
  end

  private

    def display_format_review_notes?(step_number)
      return false if format_review_notes.blank?
      return true if step_number == 3 && status_behavior.collecting_format_review_files_rejected?
      return true if step_number == 4 && !format_review_approved_at.nil?

      false
    end

    def display_final_submission_notes?(step_number)
      return false if final_submission_notes.blank?
      return true if step_number == 5 && status_behavior.collecting_final_submission_files_rejected?
      return true if step_number == 6 && !final_submission_approved_at.nil?

      false
    end

    def formatted_semester
      return semester unless semester.nil?

      '[semester not provided]'
    end

    def formatted_year
      return '[year not provided]' if year.nil?

      year.to_s
    end

    def formatted_timestamp_of(datetime)
      datetime.present? ? " on #{datetime.strftime('%B %-e, %Y')}" : ''
    end
end
