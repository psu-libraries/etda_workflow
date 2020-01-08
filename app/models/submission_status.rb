# frozen_string_literal: true

class SubmissionStatus
  attr_reader :current_submission

  WORKFLOW_STATUS =
    [
      'collecting program information',
      'collecting committee',
      'collecting format review files',
      'collecting format review files rejected',
      'waiting for format review response',
      'collecting final submission files',
      'collecting final submission files rejected',
      'waiting for final submission response',
      'waiting for committee review',
      'waiting for head of program review',
      'waiting for committee review rejected',
      'waiting for publication release',
      'released for publication metadata only',
      'released for publication',
      'format review accepted' # this is legacy FR fix
    ].freeze
  def initialize(submission)
    @current_submission = submission
  end

  def current_status
    current_submission.status
  end

  def collecting_program_information?
    current_status == 'collecting program information'
  end

  def collecting_committee?
    current_status == 'collecting committee'
  end

  def collecting_format_review_files?
    current_status == 'collecting format review files' || current_status == 'collecting format review files rejected'
  end

  def collecting_format_review_files_rejected?
    current_status.include?('collecting format review files') && !current_submission.format_review_rejected_at.nil? && current_submission.format_review_approved_at.nil?
  end

  def waiting_for_format_review_response?
    current_status == 'waiting for format review response'
  end

  def collecting_final_submission_files?
    current_status == 'collecting final submission files' || current_status == 'format review accepted' || current_status == 'collecting final submission files rejected'
  end

  def collecting_final_submission_files_rejected?
    current_status == 'collecting final submission files rejected' && !current_submission.final_submission_rejected_at.nil? && current_submission.final_submission_approved_at.nil?
  end

  def waiting_for_final_submission_response?
    current_status == 'waiting for final submission response'
  end

  def waiting_for_committee_review?
    current_status == 'waiting for committee review'
  end

  def waiting_for_head_of_program_review?
    current_status == 'waiting for head of program review'
  end

  def waiting_for_committee_review_rejected?
    current_status == 'waiting for committee review rejected'
  end

  def waiting_for_publication_release?
    current_status == 'waiting for publication release'
  end

  def released_for_publication?
    current_status == 'released for publication' || current_status == 'released for publication metadata only'
  end

  def released_for_publication_metadata_only?
    released_for_publication? && current_submission.access_level == 'restricted'
  end

  def beyond_collecting_program_information?
    collecting_committee? || beyond_collecting_committee?
  end

  def beyond_collecting_committee?
    collecting_format_review_files? || beyond_collecting_format_review_files?
  end

  def beyond_collecting_format_review_files?
    waiting_for_format_review_response? || beyond_waiting_for_format_review_response?
  end

  def beyond_waiting_for_format_review_response?
    collecting_final_submission_files? || beyond_collecting_final_submission_files?
  end

  def beyond_collecting_final_submission_files?
    current_partner.honors? ? (waiting_for_committee_review? || beyond_waiting_for_committee_review?) : (waiting_for_final_submission_response? || beyond_waiting_for_final_submission_response?)
  end

  def beyond_waiting_for_final_submission_response?
    current_partner.honors? ? (waiting_for_publication_release? || released_for_publication?) : (waiting_for_committee_review? || beyond_waiting_for_committee_review?)
  end

  def beyond_waiting_for_committee_review?
    waiting_for_head_of_program_review? || beyond_waiting_for_head_of_program_review?
  end

  def beyond_waiting_for_head_of_program_review?
    waiting_for_committee_review_rejected? || beyond_waiting_for_committee_review_rejected?
  end

  def beyond_waiting_for_committee_review_rejected?
    current_partner.honors? ? (waiting_for_final_submission_response? || beyond_waiting_for_final_submission_response?) : (waiting_for_publication_release? || released_for_publication?)
  end

  def format_review_rejected?
    collecting_format_review_files? && @current_submission.format_review_rejected_at.present?
  end

  def final_submission_rejected?
    collecting_final_submission_files? && @current_submission.final_submission_rejected_at.present?
  end

  def ok_to_update_committee?
    collecting_committee? || collecting_format_review_files? || collecting_final_submission_files?
  end
end
