# frozen_string_literal: true

# Used to indicate which status a submission is in. Primarily used for admin reports.
#
# NOTE: These statuses are duplicates of the same scopes defined in submission.rb, so
# any time a scope is added there or the logic is modified, the same change will need
# to be made in this file as well.
#
# There is probably a better way to do this without duplicating so much logic, but
# this may have to do for now.
module AdminStatuses
  extend ActiveSupport::Concern

  def admin_status
    statuses = [
      'format_review_incomplete',
      'format_review_submitted',
      'format_review_completed',
      'final_submission_pending',
      'committee_review_rejected',
      'final_submission_submitted',
      'final_submission_incomplete',
      'final_submission_approved',
      'final_submission_on_hold',
      'final_restricted_institution',
      'final_withheld',
      'released_for_publication'
    ]

    statuses.each do |s|
      return I18n.t("#{current_partner.id}.admin_filters.#{s}.title") if send(s)
    end
  end

  private

    def format_review_incomplete
      [
        'collecting program information',
        'collecting committee',
        'collecting format review files',
        'collecting format review files rejected'
      ].include?(status)
    end

    def format_review_submitted
      status == 'waiting for format review response'
    end

    def format_review_completed
      final_submission_rejected_at.nil? &&
        [
          'collecting final submission files',
          'format review is accepted'
        ].include?(status)
    end

    def final_submission_pending
      [
        'waiting for advisor review',
        'waiting for committee review',
        'waiting for head of program review'
      ].include?(status)
    end

    def committee_review_rejected
      status == 'waiting for committee review rejected'
    end

    def final_submission_incomplete
      !final_submission_rejected_at.nil? && status == 'collecting final submission files rejected'
    end

    def final_submission_submitted
      status == 'waiting for final submission response'
    end

    def final_submission_approved
      status == 'waiting for publication release'
    end

    def final_submission_on_hold
      status == 'waiting in final submission on hold'
    end

    def final_restricted_institution
      access_level == 'restricted_to_institution' && status.start_with?('released for publication')
    end

    def final_withheld
      access_level == 'restricted' && status.start_with?('released for publication')
    end

    def released_for_publication
      status.start_with?('released for publication')
    end
end
