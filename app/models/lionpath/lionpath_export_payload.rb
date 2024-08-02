class Lionpath::LionpathExportPayload
  def initialize(submission)
    @submission = submission
  end

  def to_json(*_args)
    {
      "PE_SR199_ETD_REQ": {
        "emplid": submission.author.psu_idn,
        "candNbr": submission.candidate_number,
        "thesisTitle": submission.title,
        "thesisStatus": thesis_status,
        "embargoType": embargo_type,
        "embargoStartDt": submission.released_metadata_at || '',
        "embargoEndDt": submission.released_for_publication_at || '',
        "candAdvFlg": committee_and_program_head_approved,
        "exPymtFlg": payment_received,
        "libDepFlg": federal_funding_used,
        "grdtnFlg": committee_and_program_head_approved
      }
    }.to_json
  end

  private

    attr_accessor :submission

    def status_behavior
      submission.status_behavior
    end

    def thesis_status
      return 'SUBMITTED' if status_behavior.beyond_collecting_format_review_files? &&
                            !status_behavior.beyond_waiting_for_committee_review_rejected?

      return 'APPROVED' if status_behavior.beyond_waiting_for_committee_review_rejected?

      ''
    end

    def embargo_type
      case submission.access_level
      when 'open_access'
        'OPEN'
      when 'restricted_to_institution'
        'RPSU'
      when 'restricted'
        'RSTR'
      else
        ''
      end
    end

    def committee_and_program_head_approved
      return "Y" if status_behavior.beyond_waiting_for_committee_review_rejected?

      ''
    end

    def payment_received
      return "Y" if submission.final_submission_files_uploaded_at.present?

      ''
    end

    def federal_funding_used
      return "" unless status_behavior.beyond_waiting_for_committee_review_rejected?

      return "Y" if submission.federal_funding == true

      return "N" if submission.federal_funding == false

      ''
    end
end
