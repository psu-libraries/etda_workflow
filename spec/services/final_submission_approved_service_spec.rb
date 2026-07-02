require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionApprovedService do
  let(:described_class_inst) { described_class.new(submission, 'abc123', status_giver, {}) }
  let!(:submission) { FactoryBot.create :submission, :waiting_for_publication_release }
  let(:status_giver) { SubmissionStatusGiver.new(submission) }

  before do
    allow(submission).to receive(:export_to_lionpath!)
  end

  describe '#release updated' do
    it "exports the changes to lionpath" do
      described_class_inst.release_updated
      expect(submission).to have_received(:export_to_lionpath!).once
    end
  end

  describe '#release_rejected' do
    it "changes the status and resets approval date" do
      described_class_inst.release_rejected
      expect(submission.status).to eq('waiting for final submission response')
      expect(submission.final_submission_approved_at).to be_nil
    end
  end
end
