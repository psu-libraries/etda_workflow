# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SubmissionStates::WaitingForPublicationRelease do
  describe 'instance methods' do
    let(:subject) { described_class.new }

    it "transitions to ReleasedForPublication, ReleasedForPublicationMetadataOnly WaitingForFinalSubmissionResponse, WaitingInFinalSubmissionOnHold" do
      expect(described_class.new).to be_valid_state_change(SubmissionStates::ReleasedForPublication)
      expect(described_class.new).to be_valid_state_change(SubmissionStates::WaitingInFinalSubmissionOnHold)
      expect(described_class.new).to be_valid_state_change(SubmissionStates::WaitingForFinalSubmissionResponse)
      expect(described_class.new).to be_valid_state_change(SubmissionStates::ReleasedForPublicationMetadataOnly)
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
    let(:subject) { described_class.name }

    it { is_expected.to eq 'waiting for publication release' }
  end

  describe 'status_date' do
    context 'when head of program is approving' do
      let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, head_of_program_review_accepted_at: DateTime.now }
      let(:subject) { described_class.new.status_date(submission) }

      it { is_expected.to eq(submission.head_of_program_review_accepted_at) } if current_partner.graduate?
    end

    context 'when head of program is not approving', honors: true do
      let(:submission) { FactoryBot.create :submission, :waiting_for_publication_release, committee_review_accepted_at: DateTime.now, final_submission_approved_at: DateTime.now }
      let(:subject) { described_class.new.status_date(submission) }

      it { is_expected.to eq(submission.committee_review_accepted_at) } unless current_partner.honors?
      it { is_expected.to eq(submission.final_submission_approved_at) } if current_partner.honors?
    end
  end

  describe '#transition' do
    let(:submission) { FactoryBot.create :submission, :final_is_restricted, status: status }
    let(:subject) { described_class.transition submission }

    context 'when submission status WaitingForPublicationRelease' do
      let(:status) { described_class.name }

      it { is_expected.to be_truthy }
    end

    context 'when submission status ReleasedForPublication' do
      let(:status) { SubmissionStates::ReleasedForPublication.name }

      it { is_expected.to be_truthy }
    end

    context 'when submission status ReleasedForPublicationMetadataOnly' do
      let(:status) { SubmissionStates::ReleasedForPublicationMetadataOnly.name }

      it { is_expected.to be_truthy }
    end

    context 'when submission status WaitingForFinalSubmissionResponse', honors: true do
      let(:status) { SubmissionStates::WaitingForFinalSubmissionResponse.name }

      it { is_expected.to be_falsey } unless current_partner.honors?
      it { is_expected.to be_truthy } if current_partner.honors?
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

    context 'when submission status WaitingForCommitteeReview', honors: true do
      let(:status) { SubmissionStates::WaitingForCommitteeReview.name }

      it { is_expected.to be_truthy } unless current_partner.honors?
      it { is_expected.to be_falsey } if current_partner.honors?
    end

    context 'when submission status WaitingForHeadOfProgramReview' do
      let(:status) { SubmissionStates::WaitingForHeadOfProgramReview.name }

      it { is_expected.to be_truthy }
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
