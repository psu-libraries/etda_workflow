require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SubmissionStatusUpdaterService do
  describe '#update_status_from_committee' do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:approval_configuration) do
      FactoryBot.create :approval_configuration, head_of_program_is_approving: true, degree_type: DegreeType.default
    end

    context 'when status is waiting for advisor review' do
      context 'when advisor approves and there are no funding discrepancies' do
        it 'changes status to waiting for committee review' do
          submission = FactoryBot.create :submission, :waiting_for_advisor_review, degree: degree
          create_committee submission
          submission.reload
          submission.federal_funding = true
          advisor = CommitteeMember.advisors(submission).first
          advisor.status = 'approved'
          advisor.federal_funding_used = true
          described_class.new(submission).update_status_from_committee
          submission.reload
          expect(submission.status).to eq 'waiting for committee review'
          expect(WorkflowMailer.deliveries.count).to eq submission.committee_members.count - 1
        end
      end

      context 'when advisor approves and there are funding discrepancies' do
        it 'changes status to waiting for committee review rejected' do
          submission = FactoryBot.create :submission, :waiting_for_advisor_review, degree: degree
          create_committee submission
          submission.reload
          submission.federal_funding = false
          advisor = CommitteeMember.advisors(submission).first
          advisor.status = 'approved'
          advisor.federal_funding_used = true
          described_class.new(submission).update_status_from_committee
          submission.reload
          expect(submission.status).to eq 'waiting for committee review rejected'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end
      end

      context 'when advisor rejects' do
        it 'changes status to waiting for committee review rejected' do
          submission = FactoryBot.create :submission, :waiting_for_advisor_review, degree: degree
          create_committee submission
          submission.reload
          submission.federal_funding = true
          advisor = CommitteeMember.advisors(submission).first
          advisor.status = 'rejected'
          advisor.federal_funding_used = true
          described_class.new(submission).update_status_from_committee
          submission.reload
          expect(submission.status).to eq 'waiting for committee review rejected'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end
      end
    end

    context 'when status is waiting for committee review' do
      context 'when approval status is approved' do
        it 'changes status to waiting for head of program review if program head is approving' do
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
          allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('')
          submission = FactoryBot.create :submission, :waiting_for_committee_review
          allow(CommitteeMember).to receive(:program_head).with(submission).and_return(FactoryBot.create(:committee_member))
          described_class.new(submission).update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for head of program review'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end

        it 'changes status to waiting for final submission response' do
          allow_any_instance_of(Submission).to receive(:head_of_program_is_approving?).and_return false
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
          submission = FactoryBot.create :submission, :waiting_for_committee_review
          allow(CommitteeMember).to receive(:program_head).with(submission).and_return(FactoryBot.create(:committee_member))
          described_class.new(submission).update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end
      end
    end

    context 'when approval status is rejected' do
      it 'changes status to waiting for committee review rejected' do
        allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('rejected')
        submission = FactoryBot.create :submission, :waiting_for_committee_review
        described_class.new(submission).update_status_from_committee
        expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
      end
    end

    context 'when status is waiting for head of program review' do
      context 'when approval head of program status is approved' do
        it 'changes status to waiting for final submission response if graduate school' do
          allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('approved')
          submission = FactoryBot.create :submission, :waiting_for_head_of_program_review
          described_class.new(submission).update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
        end
      end

      context 'when approval head of program status is rejected' do
        it 'changes status to waiting for committee review rejected' do
          allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('rejected')
          submission = FactoryBot.create :submission, :waiting_for_head_of_program_review
          described_class.new(submission).update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
        end
      end
    end
  end
end
