class FinalSubmissionSubmitService
  attr_accessor :submission, :status_giver, :final_submission_params

  def initialize(submission, status_giver, final_submission_params)
    @submission = submission
    @status_giver = status_giver
    @final_submission_params = final_submission_params
  end

  def submit_final_submission
    status_giver.can_upload_final_submission_files?
    submission.update!(final_submission_params)
    submission.update_attribute :publication_release_terms_agreed_to_at, Time.zone.now
    case submission.status
    when 'waiting for committee review rejected'
      committee_reject_submit
      return
    when 'collecting final submission files rejected'
      final_sub_reject_submit
      return
    end
    collect_final_sub_submit
  end

  private

    def committee_reject_submit
      submission.reset_committee_reviews
      collect_final
      submission.update_final_submission_timestamps!(Time.zone.now)
      WorkflowMailer.send_final_submission_received_email(submission)
    end

    def final_sub_reject_submit
      status_giver.can_waiting_for_final_submission_response?
      status_giver.waiting_for_final_submission_response!
      submission.update_final_submission_timestamps!(Time.zone.now)
      WorkflowMailer.send_final_submission_received_email(submission)
    end

    def collect_final_sub_submit
      collect_final
      submission.update_final_submission_timestamps!(Time.zone.now)
      WorkflowMailer.send_final_submission_received_email(submission)
    end

    def collect_final
      if current_partner.graduate? && submission.advisor.present?
        status_giver.can_waiting_for_advisor_review?
        status_giver.waiting_for_advisor_review!
        submission.advisor.update approval_started_at: DateTime.now
        if submission.advisor.status == 'approved'
          SubmissionStatusUpdaterService.new(submission).update_status_from_committee
        else
          WorkflowMailer.committee_member_review_request(submission, submission.advisor).deliver
          CommitteeReminderWorker.perform_in(4.days, submission.id, submission.advisor.id)
        end
      else
        initiate_committee_review
      end
    end

    def initiate_committee_review
      status_giver.can_waiting_for_committee_review?
      status_giver.waiting_for_committee_review!
      SeventhDayEvaluationWorker.perform_in(7.days, submission.id) if %w[approved rejected].exclude? approval_status
      submission.committee_review_requests_init
      SubmissionStatusUpdaterService.new(submission).update_status_from_committee
    end

    def approval_status
      submission.approval_status_behavior.status
    end
end
