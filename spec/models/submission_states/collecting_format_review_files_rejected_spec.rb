# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SubmissionStates::CollectingFormatReviewFilesRejected do
  describe 'instance methods' do
    let(:subject) { described_class.new }

    it "transitions to Waiting For Format Review Response" do
      expect(described_class.new).to be_valid_state_change(SubmissionStates::WaitingForFormatReviewResponse)
      expect(described_class.new).not_to be_valid_state_change(described_class)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingFinalSubmissionFiles)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingFinalSubmissionFilesRejected)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingCommittee)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingProgramInformation)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::ReleasedForPublication)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::ReleasedForPublicationMetadataOnly)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::WaitingForFinalSubmissionResponse)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::WaitingForPublicationRelease)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::Bogus)
    end
  end

  describe 'name' do
    let(:subject) { described_class.name }

    it { is_expected.to eq 'collecting format review files rejected' }
  end

  describe 'status_date' do
    let(:submission) { FactoryBot.create :submission, :collecting_format_review_files_rejected }
    let(:subject) { described_class.new.status_date(submission) }

    it { is_expected.to eq(submission.format_review_rejected_at) }
  end

  describe '#transition' do
    let(:submission) { FactoryBot.create :submission, :final_is_restricted, status: status }
    let(:subject) { described_class.transition submission }

    context 'when submission status CollectingFormatReviewFiles' do
      let(:status) { described_class.name }

      it { is_expected.to be_truthy }
    end

    context 'when submission status WaitingForFormatReviewResponse' do
      let(:status) { SubmissionStates::WaitingForFormatReviewResponse.name }

      it { is_expected.to be_truthy }
    end

    context 'when submission status CollectingCommittee' do
      let(:status) { SubmissionStates::CollectingCommittee.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingFinalSubmissionFiles' do
      let(:status) { SubmissionStates::CollectingFinalSubmissionFiles.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingFinalSubmissionFilesRejected' do
      let(:status) { SubmissionStates::CollectingFinalSubmissionFiles.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status WaitingForFinalSubmissionResponse' do
      let(:status) { SubmissionStates::WaitingForFinalSubmissionResponse.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status WaitingForPublicationRelease' do
      let(:status) { SubmissionStates::WaitingForPublicationRelease.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status ReleasedForPublication' do
      let(:status) { SubmissionStates::ReleasedForPublication.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status ReleasedForPublicationMetadataOnly' do
      let(:status) { SubmissionStates::ReleasedForPublicationMetadataOnly.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingProgramInformation' do
      let(:status) { SubmissionStates::CollectingProgramInformation.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status FormatReviewAccepted' do
      let(:status) { SubmissionStates::FormatReviewAccepted.name }

      it { is_expected.to be_falsey }
    end
  end
end
