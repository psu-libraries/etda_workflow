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
    it "sends submissions to 'waiting for committee review rejected'" do
      described_class_inst.final_rejected_send_committee
      expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
    end
  end
end
