# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SubmissionsController, type: :controller do
  describe '#redirect_to_default_dashboard' do
    it 'redirects to default dashboard' do
      expect(get: admin_root_path).to route_to(controller: 'admin/submissions', action: 'redirect_to_default_dashboard')
    end
  end
  describe '#dashboard' do
    it 'displays dashboard index' do
      expect(get: admin_submissions_dashboard_path(DegreeType.default)).to route_to(controller: 'admin/submissions', action: 'dashboard', 'degree_type': DegreeType.default.slug)
    end
  end

  describe '#edit' do
    submission = FactoryBot.create :submission
    it 'edits a submission' do
      expect(get: admin_edit_submission_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'edit', 'id': submission.id.to_s)
    end
  end

  describe '#update' do
    submission = FactoryBot.create :submission
    it 'updates a submission' do
      expect(patch: admin_submission_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'update', 'id': submission.id.to_s)
    end
  end

  describe '#index' do
    it 'displays a submissions index page for format_review_submitted filter' do
      scope = 'format_review_is_submitted'
      expect(get: admin_submissions_index_path(DegreeType.default.slug, scope)).to route_to(controller: 'admin/submissions', action: 'index', degree_type: DegreeType.default.slug, scope: 'format_review_is_submitted')
    end
    it 'displays a submissions index page for final submissions submitted filter' do
      scope = 'final_submission_is_submitted'
      expect(get: admin_submissions_index_path(DegreeType.default.slug, scope)).to route_to(controller: 'admin/submissions', action: 'index', degree_type: DegreeType.default.slug, scope: 'final_submission_is_submitted')
    end
  end

  describe '#bulk_destroy' do
    it 'deletes a group of submissions' do
      expect(delete: admin_delete_submissions_path).to route_to(controller: 'admin/submissions', action: 'bulk_destroy')
    end
  end

  describe '#release for publication' do
    it 'releases a group of submissions' do
      expect(patch: admin_submissions_release_final_submission_approved_path(DegreeType.default.id)).to route_to(controller: 'admin/submissions', action: 'release_for_publication', degree_type: DegreeType.default.id.to_s)
    end
  end

  describe '#extend_publication_date' do
    it 'extends the publication date of withheld or restricted submissions' do
      expect(patch: admin_submissions_extend_publication_date_path(DegreeType.default.id)).to route_to(controller: 'admin/submissions', action: 'extend_publication_date', degree_type: DegreeType.default.id.to_s)
    end
  end

  describe '#record_format_review_response' do
    submission = FactoryBot.create :submission, :waiting_for_format_review_response
    it 'processes the admins response to a format review that was submitted' do
      expect(patch: admin_submissions_format_review_response_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'record_format_review_response', id: submission.id.to_s)
    end
  end

  describe '#waiting_for_final_submission_response' do
    submission = FactoryBot.create :submission, :waiting_for_final_submission_response
    it 'processes the admin users\'s response to a final submission that was submitted' do
      expect(patch: admin_submissions_final_submission_response_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'record_final_submission_response', id: submission.id.to_s)
    end
  end

  describe '#update_waiting_to_be_released' do
    submission = FactoryBot.create :submission, :waiting_for_publication_release
    it 'releases a submission' do
      expect(patch: admin_submissions_update_waiting_to_be_released_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'update_waiting_to_be_released', id: submission.id.to_s)
    end
  end

  describe '#print_signatory_page' do
    submission = FactoryBot.create :submission, :waiting_for_format_review_response
    it 'displays the signatory page' do
      expect(get: admin_submission_print_signatory_page_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'print_signatory_page', id: submission.id.to_s)
    end
  end

  describe '#print_signatory_page_update' do
    submission = FactoryBot.create :submission, :waiting_for_format_review_response
    it 'updates \is_printed?\' attribute' do
      expect(patch: admin_submissions_print_signatory_page_update_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'print_signatory_page_update', id: submission.id.to_s)
    end
  end

  describe '#refresh_committee' do
    submission = FactoryBot.create :submission, :waiting_for_final_submission_response
    it 'refreshes committee information with information from Lion Path' do
      expect(get: admin_refresh_committee_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'refresh_committee', id: submission.id.to_s)
    end
  end

  describe '#refresh_academic_plan' do
    submission = FactoryBot.create :submission, :waiting_for_format_review_response
    it 'refreshes academic plan with information from Lion Path' do
      expect(get: admin_submissions_refresh_academic_plan_path(submission.id)).to route_to(controller: 'admin/submissions', action: 'refresh_academic_plan', id: submission.id.to_s)
    end
  end
end
