require 'presenters/presenters_spec_helper'
RSpec.describe Admin::SubmissionsDashboardView do
  let(:degree_type) { DegreeType.default }
  let(:view) { described_class.new(degree_type.slug) }
  let(:final_restricted) do
    {
      id: 'final-restricted-institution',
      title: I18n.t("#{current_partner.id}.admin_filters.final_restricted_institution.title"),
      description: I18n.t("#{current_partner.id}.admin_filters.final_restricted_institution.description"),
      path: nil,
      count: nil,
      sub_count: nil
    }
  end

  let(:final_restricted_view_filter) do
    a_hash_including(
      id: 'final-restricted-institution',
      path: admin_submissions_index_path(degree_type, 'final_restricted_institution'),
      count: '2',
      sub_count: '1'
    )
  end

  describe '#title' do
    it 'returns the title of the page' do
      expect(view.title).to eq DegreeType.default.name.pluralize
    end
  end

  describe '#filters' do
    context 'when no submissions exist for each filter' do
      it "returns a set of placeholders according to submission status" do
        expect(view.filters).to eq [
          {
            id: 'format-review-incomplete',
            title: I18n.t("#{current_partner.id}.admin_filters.format_review_incomplete.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.format_review_incomplete.description"),
            path: nil,
            count: nil
          },
          {
            id: 'format-review-submitted',
            title: I18n.t("#{current_partner.id}.admin_filters.format_review_submitted.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.format_review_submitted.description"),
            path: nil,
            count: nil
          },
          {
            id: 'format-review-completed',
            title: I18n.t("#{current_partner.id}.admin_filters.format_review_completed.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.format_review_completed.description"),
            path: nil,
            count: nil
          },
          {
              id: 'final-submission-submitted',
              title: I18n.t("#{current_partner.id}.admin_filters.final_submission_submitted.title"),
              description: I18n.t("#{current_partner.id}.admin_filters.final_submission_submitted.description"),
              path: nil,
              count: nil
          },
          {
              id: 'final-submission-incomplete',
              title: I18n.t("#{current_partner.id}.admin_filters.final_submission_incomplete.title"),
              description: I18n.t("#{current_partner.id}.admin_filters.final_submission_incomplete.description"),
              path: nil,
              count: nil
          },
          {
            id: 'final-submission-pending',
            title: I18n.t("#{current_partner.id}.admin_filters.final_submission_pending.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.final_submission_pending.description"),
            path: nil,
            count: nil
          },
          {
            id: 'committee-review-rejected',
            title: I18n.t("#{current_partner.id}.admin_filters.committee_review_rejected.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.committee_review_rejected.description"),
            path: nil,
            count: nil
          },
          {
            id: 'final-submission-approved',
            title: I18n.t("#{current_partner.id}.admin_filters.final_submission_approved.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.final_submission_approved.description"),
            path: nil,
            count: nil
          },
          {
            id: 'released-for-publication',
            title: I18n.t("#{current_partner.id}.admin_filters.released_for_publication.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.released_for_publication.description"),
            path: nil,
            count: nil
          },
          {   id: 'final-restricted-institution',
              title: I18n.t("#{current_partner.id}.admin_filters.final_restricted_institution.title"),
              description: I18n.t("#{current_partner.id}.admin_filters.final_restricted_institution.description"),
              path: nil,
              count: nil,
              sub_count: nil },
          {
            id: 'final-withheld',
            title: I18n.t("#{current_partner.id}.admin_filters.final_withheld.title"),
            description: I18n.t("#{current_partner.id}.admin_filters.final_withheld.description"),
            path: nil,
            count: nil,
            sub_count: nil
          }
        ]
      end
    end

    context 'when submissions exist for each filter' do
      before do
        FactoryBot.create :submission, :collecting_program_information
        FactoryBot.create :submission, :collecting_committee
        FactoryBot.create :submission, :collecting_format_review_files
        FactoryBot.create :submission, :waiting_for_format_review_response
        FactoryBot.create :submission, :collecting_final_submission_files, final_submission_rejected_at: nil
        FactoryBot.create :submission, :collecting_final_submission_files, final_submission_rejected_at: 1.day.ago
        FactoryBot.create :submission, :waiting_for_committee_review
        FactoryBot.create :submission, :waiting_for_committee_review_rejected
        FactoryBot.create :submission, :waiting_for_final_submission_response
        FactoryBot.create :submission, :waiting_for_publication_release
        FactoryBot.create :submission, :released_for_publication
        FactoryBot.create :submission, :final_is_restricted_to_institution, released_for_publication_at: 1.day.ago
        FactoryBot.create :submission, :final_is_restricted_to_institution, released_for_publication_at: 1.day.from_now
        FactoryBot.create :submission, :final_is_restricted, released_for_publication_at: 1.day.ago
        FactoryBot.create :submission, :final_is_restricted, released_for_publication_at: 1.day.from_now
      end

      it "returns a set of links according to submission status" do
        # use a_hash_including here so we don't duplicate the specs on title, description

        expect(view.filters).to match [
          a_hash_including(
            id: 'format-review-incomplete',
            path: admin_submissions_index_path(degree_type, 'format_review_incomplete'),
            count: '12'
          ),
          a_hash_including(
            id: 'format-review-submitted',
            path: admin_submissions_index_path(degree_type, 'format_review_submitted'),
            count: '1'
          ),
          a_hash_including(
            id: 'format-review-completed',
            path: admin_submissions_index_path(degree_type, 'format_review_completed'),
            count: '1'
          ),
          a_hash_including(
              id: 'final-submission-submitted',
              path: admin_submissions_index_path(degree_type, 'final_submission_submitted'),
              count: '1'
          ),
          a_hash_including(
              id: 'final-submission-incomplete',
              path: admin_submissions_index_path(degree_type, 'final_submission_incomplete'),
              count: '1'
          ),
          a_hash_including(
            id: 'final-submission-pending',
            path: admin_submissions_index_path(degree_type, 'final_submission_pending'),
            count: '1'
          ),
          a_hash_including(
            id: 'committee-review-rejected',
            path: admin_submissions_index_path(degree_type, 'committee_review_rejected'),
            count: '1'
          ),
          a_hash_including(
            id: 'final-submission-approved',
            path: admin_submissions_index_path(degree_type, 'final_submission_approved'),
            count: '1'
          ),
          a_hash_including(
            id: 'released-for-publication',
            path: admin_submissions_index_path(degree_type, 'released_for_publication'),
            count: '5'
          ),
          final_restricted_view_filter,
          a_hash_including(
            id: 'final-withheld',
            path: admin_submissions_index_path(degree_type, 'final_withheld'),
            count: '2',
            sub_count: '1'
          )
        ]
      end
    end
  end
end
