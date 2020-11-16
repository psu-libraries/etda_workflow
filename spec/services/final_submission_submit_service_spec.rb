# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionSubmitService do
  let!(:submission) { FactoryBot.create :submission, degree: degree }
  let!(:status_giver) { SubmissionStatusGiver.new(submission) }
  let!(:approval_status) { ApprovalStatus.new(submission) }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:approval_configuration) { FactoryBot.create(:approval_configuration, head_of_program_is_approving: false, degree_type: degree.degree_type) } if current_partner.honors?
  let!(:approval_configuration) { FactoryBot.create(:approval_configuration, head_of_program_is_approving: true, degree_type: degree.degree_type) } unless current_partner.honors?

  describe "#submit_final_submission" do
    context "when author submits final submission for the first time", honors: true do
      it "proceeds submission to next step in workflow" do
        submission.status = 'collecting final submission files'
        final_submission_params = {}
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('')
        FinalSubmissionSubmitService.new(submission, status_giver, approval_status, final_submission_params).submit_final_submission
        expect(Submission.find(submission.id).status).to eq 'waiting for committee review' if current_partner.honors?
        expect(Submission.find(submission.id).status).to eq 'waiting for final submission response' unless current_partner.honors?
      end
    end

    context "when author submits final submission after committee rejects", honors: true do
      it "proceeds submission to next step in workflow" do
        submission.status = 'waiting for committee review rejected'
        committee_member = FactoryBot.create :committee_member, status: 'Rejected'
        submission.committee_members << committee_member
        approval_status = ApprovalStatus.new(submission)
        final_submission_params = {}
        FinalSubmissionSubmitService.new(submission, status_giver, approval_status, final_submission_params).submit_final_submission
        expect(Submission.find(submission.id).status).to eq 'waiting for committee review' if current_partner.honors?
        expect(Submission.find(submission.id).status).to eq 'waiting for final submission response' unless current_partner.honors?
      end
    end

    context "when author submits final submission after admins reject", honors: true do
      context 'when committee status is "Approved"' do
        it "proceeds submission to next step in workflow" do
          submission.status = 'collecting final submission files rejected'
          committee_member = FactoryBot.create :committee_member, status: 'Approved'
          submission.committee_members << committee_member
          final_submission_params = {}
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
          FinalSubmissionSubmitService.new(submission, status_giver, approval_status, final_submission_params).submit_final_submission
          expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
        end
      end

      context 'when committee status is "Rejected"' do
        it "proceeds submission to next step in workflow" do
          submission.status = 'collecting final submission files rejected'
          committee_member = FactoryBot.create :committee_member, status: 'Rejected'
          submission.committee_members << committee_member
          approval_status = ApprovalStatus.new(submission)
          final_submission_params = {}
          FinalSubmissionSubmitService.new(submission, status_giver, approval_status, final_submission_params).submit_final_submission
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review' if current_partner.honors?
          expect(Submission.find(submission.id).status).to eq 'waiting for final submission response' unless current_partner.honors?
        end
      end
    end
  end
end
