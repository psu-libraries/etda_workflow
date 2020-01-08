require 'delegate'

class Admin::SubmissionFormView < SimpleDelegator
  delegate :full_name,
           :alternate_email_address,
           :phone_number, to: :author, prefix: true

  # Our submission form view should truly pose as the wrapped object,
  # since some Rails helpers will use this for naming conventions.
  delegate :class, to: :__getobj__

  def initialize(submission, session)
    # decorate here
    super(submission)
    submission.author_edit = false
    @session = session
  end

  def title
    return 'Format Review Evaluation' if status_behavior.waiting_for_format_review_response?
    return 'Edit Completed Format Review' if status_behavior.collecting_final_submission_files? && !status_behavior.final_submission_rejected?
    return 'Edit Incomplete Final Submission' if status_behavior.collecting_final_submission_files? && status_behavior.final_submission_rejected?
    return 'Waiting for Committee Review' if status_behavior.waiting_for_committee_review?
    return 'Waiting for Head/Chair Review' if status_behavior.waiting_for_head_of_program_review?
    return 'Committee Review Rejected' if status_behavior.waiting_for_committee_review_rejected?
    return 'Final Submission Evaluation' if status_behavior.waiting_for_final_submission_response?
    return 'Edit Final Submission to be Released' if status_behavior.waiting_for_publication_release?
    return 'Edit Released Submission' if status_behavior.released_for_publication? && open_access?
    return 'Edit Restricted Theses' if status_behavior.released_for_publication_metadata_only? && restricted?
    return 'Edit Final Submission is Restricted to Penn State' if status_behavior.released_for_publication? && access_level == 'restricted_to_institution'

    'Edit Incomplete Format Review'
  end

  def actions_partial_name
    return 'format_review_evaluation_actions' if status_behavior.waiting_for_format_review_response?
    return 'final_submission_evaluation_actions' if status_behavior.waiting_for_final_submission_response?
    return 'released_actions' if status_behavior.released_for_publication? && access_level.open_access?
    return 'restricted_actions' if status_behavior.released_for_publication_metadata_only?
    return 'restricted_institution_actions' if status_behavior.released_for_publication? && !(access_level.open_access? || access_level.restricted?)
    return 'to_be_released_actions' if status_behavior.waiting_for_publication_release?

    'standard_actions'
  end

  def form_for_url
    return "/admin/submissions/#{id}/format_review_response" if status_behavior.waiting_for_format_review_response?
    return "/admin/submissions/#{id}/final_submission_response" if status_behavior.waiting_for_final_submission_response?
    return "/admin/submissions/#{id}/update_waiting_to_be_released" if status_behavior.waiting_for_publication_release?
    return "/admin/submissions/#{id}/update_released" if status_behavior.released_for_publication?

    "/admin/submissions/#{id}"
  end

  def cancellation_path
    # @session_delete ||= @session.delete(:return_to)
    cancel_url
  end

  def address
    address = author.address_1.present? ? "#{author.address_1}<br />" : ''
    address << "#{author.address_2}<br />" if author.address_2.present?
    address << "#{author.city}, " if author.city.present?
    address << "#{author.state} #{author.zip}"
  end

  def using_lionpath_record?
    using_lionpath?
  end

  def committee_form
    return 'standard_committee_form' unless using_lionpath?

    'lionpath_committee_form'
  end

  def program_information_partial
    return 'standard_program_information' unless using_lionpath?

    'lionpath_program_information'
  end

  def defense_date_partial_for_final_fields
    # defense date is hidden when using lionpath b/c it's displayed in format review section
    # hidden value is necessary when editing
    # standard datepicker displays when lion path is not active
    return '/admin/submissions/edit/standard_defended_at_date' unless using_lionpath?

    '/admin/submissions/edit/defended_at_date_hidden'
  end

  def psu_only(label)
    label == AccessLevel.paper_access_levels[AccessLevel.RESTRICTED_TO_INSTITUTION.to_i][:label] && Partner.current.milsch? # 'Restricted (Penn State Only)'
  end

  def release_date_history
    return '' unless status_behavior.released_for_publication?

    case access_level
    when 'restricted'
        "<b>Metadata released:</b> #{date_information(released_metadata_at)}<br /><b>Scheduled for full release: </b> #{date_information(released_for_publication_at)}".html_safe
    when 'restricted_to_institution'
        "<b>Released to Penn State Community: </b> #{date_information(released_metadata_at)}<br /><b>Scheduled for full release: </b>#{date_information(released_for_publication_at)}".html_safe
    else
        metadata_str = ''
        metadata_str = "<b>Metadata released:</b> #{date_information(released_metadata_at)}<br />" unless released_metadata_at.nil?
        metadata_str + "<b>Released for publication: </b>#{date_information(released_for_publication_at)}".html_safe
    end
  end

  def date_information(date_in)
    return 'Unknown' if date_in.blank?

    date_in.strftime('%Y-%m-%d')
  end

  def withdraw_message
    return '' unless status_behavior.released_for_publication?

    '<div class="withdraw-msg">In order to update a published submission, it must be withdrawn from publication.  After withdrawing, the submission can be edited and re-published.   Any changes made to the submission while it is released will <strong>NOT</strong> be saved.  The withdraw button is at the bottom of the page.</div>'.html_safe
  end

  def form_section_heading(section_heading)
    return "class='form-section-heading collapsed' aria-expanded='false'".html_safe if collapse_content?(section_heading)

    "class='form-section-heading collapse in'".html_safe
  end

  def chevron_class(section_heading)
    return '' if collapse_content?(section_heading)

    'fa-rotate-90'
  end

  def form_section_body(section_heading)
    return "class='form-section-body collapse' aria-expanded='false'".html_safe if collapse_content?(section_heading)

    "class='form-section-body collapse in'".html_safe
  end

  def button_message
    if approval_status_behavior.status == 'approved' && approval_status_behavior.head_of_program_status == 'approved' && degree.degree_type.approval_configuration.head_of_program_is_approving
      "Final Submission to be Released"
    elsif approval_status_behavior.status == 'approved' && !degree.degree_type.approval_configuration.head_of_program_is_approving
      "Final Submission to be Released"
    elsif approval_status_behavior.status == 'rejected' || approval_status_behavior.head_of_program_status == 'rejected'
      "Committee Review Rejected"
    else
      "Final Submission is Pending"
    end
  end

  def confirmation_message
    if approval_status_behavior.status == 'approved' && approval_status_behavior.head_of_program_status == 'approved' && degree.degree_type.approval_configuration.head_of_program_is_approving
      "The committee for this submission has already approved.  Move this submission to 'Final Submission to be Released' and skip the committee review?"
    elsif approval_status_behavior.status == 'approved' && !degree.degree_type.approval_configuration.head_of_program_is_approving
      "The committee for this submission has already approved.  Move this submission to 'Final Submission to be Released' and skip the committee review?"
    elsif approval_status_behavior.status == 'rejected' || approval_status_behavior.head_of_program_status == 'rejected'
      "The committee for this submission has already rejected.  Move this submission to 'Committee Review Rejected' and skip the committee review?"
    else
      "Are you sure you would like to approve this submission?  This will initiate the committee review stage, which will send emails out to members of the committee."
    end
  end

  private

    def collapse_content?(section_heading)
      return false if status == 'waiting for format review response' && section_heading == 'format-review-files'
      return true if status_behavior.beyond_collecting_format_review_files? && (section_heading == 'program-information' || section_heading == 'committee' || section_heading == 'format-review-files')

      false
    end

    def cancel_url
      return "/admin/#{degree_type.slug}/format_review_submitted" if status_behavior.waiting_for_format_review_response?
      return "/admin/#{degree_type.slug}/format_review_completed" if status_behavior.collecting_final_submission_files? && !status_behavior.final_submission_rejected?
      return "/admin/#{degree_type.slug}/final_submission_incomplete" if status_behavior.collecting_final_submission_files_rejected? && status_behavior.final_submission_rejected?
      return "/admin/#{degree_type.slug}/final_submission_submitted" if status_behavior.waiting_for_final_submission_response?
      return "/admin/#{degree_type.slug}/final_submission_pending" if status_behavior.waiting_for_committee_review?
      return "/admin/#{degree_type.slug}/committee_review_rejected" if status_behavior.waiting_for_committee_review_rejected?
      return "/admin/#{degree_type.slug}/final_submission_approved" if status_behavior.waiting_for_publication_release?
      #  return "/admin/#{degree_type}/released_for_publication" if status_behavior.released_for_publication? && open_access?  TOO SLOW; RETURN TO DASHBOARD
      return "/admin/#{degree_type.slug}" if status_behavior.released_for_publication? && open_access?
      return "/admin/#{degree_type.slug}/final_withheld" if status_behavior.released_for_publication_metadata_only? && restricted?
      return "/admin/#{degree_type.slug}/final_restricted_institution" if status_behavior.released_for_publication? && access_level == 'restricted_to_institution'

      "/admin/#{degree_type.slug}/format_review_incomplete"
    end
end
