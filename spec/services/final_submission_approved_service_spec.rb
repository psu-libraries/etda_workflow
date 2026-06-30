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

  describe '#release_sent_to_hold' do
    it "changes the status and sets the placed_on_hold_at date" do
      described_class_inst.release_sent_to_hold
      expect(submission.status).to eq('waiting in final submission on hold')
      expect(submission.placed_on_hold_at.today?).to be(true)
    end
  end

  describe '#release_remove_hold' do
    before do
      submission.update!(status: 'waiting in final submission on hold')
    end

    it 'changes the staus and sets removed_hold_at date' do
      described_class_inst.release_remove_hold
      expect(submission.status).to eq('waiting for publication release')
      expect(submission.removed_hold_at.today?).to be(true)
    end
  end
end
