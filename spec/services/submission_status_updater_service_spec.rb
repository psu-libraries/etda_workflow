require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SubmissionStatusUpdaterService do

  describe '#update_status_from_committee' do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:degree_type) { FactoryBot.create :degree_type }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, head_of_program_is_approving: true, degree_type_id: degree_type.id }

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
