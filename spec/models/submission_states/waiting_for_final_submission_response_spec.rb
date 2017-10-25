require 'rails_helper'
require 'shoulda-matchers'
require 'support/request_spec_helper'

RSpec.describe SubmissionStates::WaitingForFinalSubmissionResponse do
  describe 'instance methods' do
    let(:subject) { described_class.new }

    it "transitions to WaitingForPublication and CollectingFinalSubmissionFiles" do
      expect(subject.valid_state_change?(SubmissionStates::WaitingForPublicationRelease)).to be_truthy
      expect(subject.valid_state_change?(SubmissionStates::CollectingFinalSubmissionFiles)).to be_truthy
      expect(subject.valid_state_change?(SubmissionStates::CollectingFinalSubmissionFilesRejected)).to be_truthy
      expect(subject.valid_state_change?(SubmissionStates::CollectingCommittee)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::CollectingFormatReviewFiles)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::CollectingFormatReviewFilesRejected)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::CollectingProgramInformation)).to be_falsey
      expect(subject.valid_state_change?(described_class)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::WaitingForFormatReviewResponse)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::ReleasedForPublication)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::ReleasedForPublicationMetadataOnly)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::Bogus)).to be_falsey
      expect(subject.valid_state_change?(SubmissionStates::ConfidentialHoldEmbargo)).to be_truthy
    end
  end

  describe 'name' do
    let(:subject) { described_class.name }
    it { is_expected.to eq 'waiting for final submission response' }
  end

  describe 'status_date' do
    let(:submission) { FactoryBot.create :submission, :waiting_for_final_submission_response }
    let(:subject) { described_class.new.status_date(submission) }
    it { is_expected.to eq(submission.final_submission_files_uploaded_at) }
  end

  describe '#transition' do
    let(:submission) { FactoryBot.create :submission, :final_is_restricted, status: status }
    let(:subject) { described_class.transition submission }

    context 'when submission status WaitingForFinalSubmissionResponse' do
      let(:status) { described_class.name }
      it { is_expected.to be_truthy }
    end

    context 'when submission status CollectingFinalSubmissionFiles' do
      let(:status) { SubmissionStates::CollectingFinalSubmissionFiles.name }
      it { is_expected.to be_truthy }
    end

    context 'when submission status CollectingFinalSubmissionFilesRejected' do
      let(:status) { SubmissionStates::CollectingFinalSubmissionFilesRejected.name }
      it { is_expected.to be_truthy }
    end

    context 'when submission status FormatReviewAccepted' do
      let(:status) { SubmissionStates::FormatReviewAccepted.name }
      it { is_expected.to be_truthy }
    end

    context 'when submissions status WaitingForFormatReviewResponse and author has a confidential hold' do
      it 'transitions to confidential hold embargo' do
        allow_any_instance_of(Author).to receive(:confidential?).and_return true
        expect(SubmissionStates::ConfidentialHoldEmbargo).to be_truthy
      end
    end

    context 'when submission status WaitingForPublicationRelease' do
      let(:status) { SubmissionStates::WaitingForPublicationRelease.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status ReleasedForPublication' do
      let(:status) { SubmissionStates::ReleasedForPublication.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingProgramInformation' do
      let(:status) { SubmissionStates::CollectingProgramInformation.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingCommittee' do
      let(:status) { SubmissionStates::CollectingCommittee.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingFormatReviewFiles' do
      let(:status) { SubmissionStates::CollectingFormatReviewFiles.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingFormatReviewFilesRejected' do
      let(:status) { SubmissionStates::CollectingFormatReviewFilesRejected.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingProgramInformation' do
      let(:status) { SubmissionStates::CollectingProgramInformation.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status WaitingForFormatReviewResponse' do
      let(:status) { SubmissionStates::WaitingForFormatReviewResponse.name }
      it { is_expected.to be_falsey }
    end

    context 'when submission status ReleasedForPublicationMetadataOnly' do
      let(:status) { SubmissionStates::ReleasedForPublicationMetadataOnly.name }
      it { is_expected.to be_falsey }
    end
  end
end
