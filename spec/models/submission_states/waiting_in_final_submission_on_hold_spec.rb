# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SubmissionStates::WaitingInFinalSubmissionOnHold do
  describe 'instance methods' do
    subject { described_class.new }

    it "transitions to WaitingForPublicationRelease" do
      expect(described_class.new).to be_valid_state_change(SubmissionStates::WaitingForPublicationRelease)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::ReleasedForPublication)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::WaitingForFinalSubmissionResponse)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::ReleasedForPublicationMetadataOnly)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingCommittee)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingFormatReviewFiles)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingFormatReviewFilesRejected)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingFinalSubmissionFiles)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingFinalSubmissionFilesRejected)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::CollectingProgramInformation)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::WaitingForHeadOfProgramReview)
      expect(described_class.new).not_to be_valid_state_change(described_class)
      expect(described_class.new).not_to be_valid_state_change(SubmissionStates::Bogus)
    end
  end

  describe 'name' do
    subject { described_class.name }

    it { is_expected.to eq 'waiting in final submission on hold' }
  end

  describe 'status_date' do
    subject { described_class.new.status_date(submission) }

    let(:submission) { FactoryBot.create :submission, :waiting_in_final_submission_on_hold, placed_on_hold_at: DateTime.now }

    it { is_expected.to eq(submission.placed_on_hold_at) }
  end

  describe '#transition' do
    subject { described_class.transition submission }

    let(:submission) { FactoryBot.create :submission, :final_is_restricted, status: }

    context 'when submission status WaitingInFinalSubmissionOnHold' do
      let(:status) { described_class.name }

      it { is_expected.to be_truthy }
    end

    context 'when submission status WaitingForPublicationRelease' do
      let(:status) { SubmissionStates::WaitingForPublicationRelease.name }

      it { is_expected.to be_truthy }
    end

    context 'when submission status ReleasedForPublication' do
      let(:status) { SubmissionStates::ReleasedForPublication.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status ReleasedForPublicationMetadataOnly' do
      let(:status) { SubmissionStates::ReleasedForPublicationMetadataOnly.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status WaitingForFinalSubmissionResponse' do
      let(:status) { SubmissionStates::WaitingForFinalSubmissionResponse.name }

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

    context 'when submission status CollectingFinalSubmissionFiles' do
      let(:status) { SubmissionStates::CollectingFinalSubmissionFiles.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status WaitingForCommitteeReview' do
      let(:status) { SubmissionStates::WaitingForCommitteeReview.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status WaitingForHeadOfProgramReview' do
      let(:status) { SubmissionStates::WaitingForHeadOfProgramReview.name }

      it { is_expected.to be_falsey }
    end

    context 'when submission status CollectingFinalSubmissionFilesRejected' do
      let(:status) { SubmissionStates::CollectingFormatReviewFilesRejected.name }

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

    context 'when submission status FormatReviewAccepted' do
      let(:status) { SubmissionStates::FormatReviewAccepted.name }

      it { is_expected.to be_falsey }
    end
  end
end
