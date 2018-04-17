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
    @session_delete ||= @session.delete(:return_to)
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
    label == AccessLevel.paper_access_levels[AccessLevel.RESTRICTED_TO_INSTITUTION.to_i][:label] && !Partner.current.graduate? # 'Restricted (Penn State Only)'
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
    '<div class="withdraw-msg">In order to update a published submission, it must be withdrawn from publication and then released.  The withdraw button is at the bottom of the page.</div>'.html_safe
  end
end
