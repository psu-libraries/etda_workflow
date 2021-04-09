require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionSubmittedService do
  let(:described_class_inst) { described_class.new(submission, 'abc123', status_giver, {}) }
  let!(:submission) { FactoryBot.create :submission, :waiting_for_final_submission_response }
  let(:status_giver) { SubmissionStatusGiver.new(submission) }

  describe '#final_submission_approved' do
    it "sends submissions to 'waiting for publication release'" do
      described_class_inst.final_submission_approved
      expect(Submission.find(submission.id).status).to eq 'waiting for publication release'
    end
  end

  describe '#final_submission_rejected' do
    it "sends submissions to 'collecting final submission files rejected'" do
      described_class_inst.final_submission_rejected
      expect(Submission.find(submission.id).status).to eq 'collecting final submission files rejected'
    end
  end

  describe '#final_rejected_send_committee' do
    it "sends submissions to 'waiting for committee review'" do
      described_class_inst.final_rejected_send_committee
      expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
    end
  end

  describe '#final_rejected_send_committee' do
    before do
      create_committee(submission)
      submission.committee_members << FactoryBot.create(:committee_member,
                                                        committee_role: CommitteeRole.find_by(degree_type: submission.degree_type,
                                                                                              is_program_head: true))
      submission.committee_members.each do |cm|
        cm.update status: 'approved'
      end
    end
    it "sends submissions to 'waiting for head of program review'" do
      described_class_inst.final_rejected_send_dept_head
      submission.reload
      expect(submission.status).to eq 'waiting for head of program review'
      expect(WorkflowMailer.deliveries.count).to eq 1
      expect(submission.program_head.status).to eq ''
    end
  end
end
