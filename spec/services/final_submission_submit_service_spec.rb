require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionSubmitService do
  let!(:submission) { FactoryBot.create :submission, :collecting_final_submission_files_rejected }
  let(:status_giver) { SubmissionStatusGiver.new(submission) }

  before do
    create_committee(submission)
  end

  context 'when submission is submitted after admin rejection, and approval status is "rejected"' do
    it 'proceeds to the "waiting for committee review" stage' do
      service = described_class.new(submission, status_giver, {})
      allow(service).to receive(:approval_status).and_return 'rejected'
      service.submit_final_submission
      expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
      expect(WorkflowMailer.deliveries.count).to eq 6
    end
  end

  context 'when submission is submitted after admin rejection, and approval status is "approved"' do
    it 'proceeds to the "waiting for final submission response" stage' do
      service = described_class.new(submission, status_giver, {})
      allow(service).to receive(:approval_status).and_return 'approved'
      service.submit_final_submission
      expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
      expect(WorkflowMailer.deliveries.count).to eq 1
    end
  end
end
