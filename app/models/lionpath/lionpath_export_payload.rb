class Lionpath::LionpathExportPayload
  def initialize(submission)
    @submission = submission
  end

  def json_payload
    internal_data = {}
    {
      "emplid" => submission.author.psu_idn,
      "candNbr" => submission.candidate_number,
      "thesisTitle" => submission.title,
      "thesisStatus" => thesis_status,
      "embargoType" => embargo_type,
      "embargoStartDt" => submission.released_metadata_at&.strftime("%Y%m%d"),
      "embargoEndDt" => submission.released_for_publication_at&.strftime("%Y%m%d"),
      "candAdvFlg" => core_committee_approved,
      "exPymtFlg" => payment_received,
      "libDepFlg" => federal_funding_used,
      "grdtnFlg" => final_submission_approved
    }.each do |key, value|
      internal_data[key] = value if value
    end
    { "PE_SR199_ETD_REQ": internal_data }.to_json
  end

  private

    attr_reader :submission

    def status_behavior
      submission.status_behavior
    end

    def committee_approved_status?
      submission.approval_status_behavior.status == ApprovalStatus::APPROVED_STATUS
    end

    def thesis_status
      return 'SUBMITTED' if status_behavior.beyond_collecting_format_review_files? &&
                            !status_behavior.beyond_waiting_for_final_submission_response_rejected?

      return 'APPROVED' if status_behavior.beyond_waiting_for_final_submission_response_rejected?

      nil
    end

    def embargo_type
      access_level_map = {
        'open_access' => 'OPEN',
        'restricted_to_institution' => 'RPSU',
        'restricted' => 'RSTR'
      }
      access_level_map[submission.access_level]
    end

    def final_submission_approved
      return "Y" if status_behavior.beyond_waiting_for_final_submission_response_rejected?

      nil
    end

    def core_committee_approved
      return "Y" if status_behavior.beyond_waiting_for_committee_review? &&
                    !status_behavior.waiting_for_committee_review_rejected?

      nil
    end

    def payment_received
      return "Y" if submission.final_submission_files_uploaded_at.present?

      nil
    end

    def federal_funding_used
      return nil unless status_behavior.beyond_waiting_for_committee_review_rejected?

      return "Y" if submission.federal_funding == true

      return "N" if submission.federal_funding == false

      nil
    end
end
