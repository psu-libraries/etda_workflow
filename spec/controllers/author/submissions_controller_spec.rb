# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author::SubmissionsController, type: :controller do
  describe '#index' do
    it 'displays all current submissions for an author' do
      expect(get: author_root_path).to route_to(controller: 'author/submissions', action: 'index')
    end
  end

  describe '#new' do
    it 'initializes a new submission for an author' do
      expect(get: new_author_submission_path).to route_to(controller: 'author/submissions', action: 'new')
    end
  end

  describe '#create' do
    it 'creates a new submission for an author' do
      expect(post: author_submissions_path).to route_to(controller: 'author/submissions', action: 'create')
    end
  end

  describe '#edit' do
    it 'routes to the edit page' do
      submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
      expect(get: edit_author_submission_path(submission.id)).to route_to(controller: 'author/submissions', action: 'edit', id: submission.id.to_s)
    end

    if current_partner.graduate?
      it 'redirects to the acknowledge page if acknowledgement page has not been viewed' do
        oidc_authorize_author
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
        params = { id: submission.id.to_s }
        allow(controller).to receive(:find_submission).and_return(submission)
        expect(get(:edit, params:)).to redirect_to author_submission_acknowledge_path(submission.id)
      end

      it 'renders the edit page if the acknowledgement page has been viewed' do
        oidc_authorize_author
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: Time.zone.now)
        params = { id: submission.id.to_s }
        allow(controller).to receive(:find_submission).and_return(submission)
        expect(get(:edit, params:)).to render_template(:edit)
      end
    end

    unless current_partner.graduate?
      it 'renders the edit page regardless of the acknowledgment page status', honors: true, sset: true, milsch: true do
        oidc_authorize_author
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
        params = { id: submission.id.to_s }
        allow(controller).to receive(:find_submission).and_return(submission)
        expect(get(:edit, params:)).to render_template(:edit)

        submission2 = FactoryBot.create(:submission, acknowledgment_page_submitted_at: Time.zone.now)
        params = { id: submission2.id.to_s }
        allow(controller).to receive(:find_submission).and_return(submission2)
        expect(get(:edit, params:)).to render_template(:edit)
      end
    end
  end

  describe '#acknowledge' do
    if current_partner.graduate?
      it 'follows correct route' do
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
        expect(get: author_submission_acknowledge_path(submission.id)).to route_to(controller: 'author/submissions', action: 'acknowledge', submission_id: submission.id.to_s)
      end
    end
  end

  describe '#acknowledge_update' do
    if current_partner.graduate?
      it 'follows correct route' do
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
        expect(patch: author_submission_acknowledge_update_path(submission.id)).to route_to(controller: 'author/submissions', action: 'acknowledge_update', submission_id: submission.id.to_s)
      end

      it 'redirects back to acknowledge page with an alert if the user does not initial for every statement' do
        oidc_authorize_author
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
        params = { acknowledgment_signatures: { sig_1: '', sig_2: '', sig_3: '3', sig_4: '4', sig_5: '5', sig_6: '6', sig_7: '7' }, submission_id: submission.id.to_s }
        expect(patch(:acknowledge_update, params:)).to redirect_to author_submission_acknowledge_path(submission.id)
        expect(flash[:alert]).to be_present
      end

      it 'redirects back to edit page if the user submits valid program information data' do
        oidc_authorize_author
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
        params = { acknowledgment_signatures: { sig_1: '1', sig_2: '2', sig_3: '3', sig_4: '4', sig_5: '5', sig_6: '6', sig_7: '7' }, submission_id: submission.id.to_s }
        allow(controller).to receive(:find_submission).and_return(submission)
        expect(patch(:acknowledge_update, params:)).to redirect_to edit_author_submission_path(submission.id)
        expect(flash[:alert]).not_to be_present
      end

      it 'save the updated submission if the user submits valid program information data' do
        oidc_authorize_author
        submission = FactoryBot.create(:submission, acknowledgment_page_submitted_at: nil)
        params = { acknowledgment_signatures: { sig_1: '1', sig_2: '2', sig_3: '3', sig_4: '4', sig_5: '5', sig_6: '6', sig_7: '7' }, submission_id: submission.id.to_s }
        allow(controller).to receive(:find_submission).and_return(submission)
        patch(:acknowledge_update, params:)
        expect(submission.reload.acknowledgment_page_submitted_at).not_to be_nil
        expect(submission).to be_persisted
      end
    end
  end

  describe '#update' do
    it 'updates a submission for an author' do
      submission = FactoryBot.create :submission
      expect(patch: author_submission_path(submission.id)).to route_to(controller: 'author/submissions', action: 'update', id: submission.id.to_s)
    end
  end

  describe '#destroy' do
    it 'deletes a submission for an author' do
      submission = FactoryBot.create :submission
      expect(delete: author_submission_path(submission.id)).to route_to(controller: 'author/submissions', action: 'destroy', id: submission.id.to_s)
    end
  end

  describe '#program_information' do
    it 'displays the program information for an author\'s submission' do
      submission = FactoryBot.create :submission
      expect(get: author_submission_program_information_path(submission.id)).to route_to(controller: 'author/submissions', action: 'program_information', submission_id: submission.id.to_s)
    end
  end

  describe '#edit_final_submission' do
    it 'edits the final submission information for an author' do
      submission = FactoryBot.create :submission
      expect(get: author_submission_edit_final_submission_path(submission.id)).to route_to(controller: 'author/submissions', action: 'edit_final_submission', submission_id: submission.id.to_s)
    end
  end

  describe '#update_final_submission' do
    it 'updates the final submission information for an author' do
      submission = FactoryBot.create :submission
      expect(patch: author_submission_update_final_submission_path(submission.id)).to route_to(controller: 'author/submissions', action: 'update_final_submission', submission_id: submission.id.to_s)
    end
  end

  describe '#edit_final_submission' do
    it 'displays the final submission information for an author to review' do
      submission = FactoryBot.create :submission
      expect(get: author_submission_final_submission_path(submission.id)).to route_to(controller: 'author/submissions', action: 'final_submission', submission_id: submission.id.to_s)
    end
  end

  describe '#send_email_reminder' do
    it 'routes to author/submissions/[:submission_id]/send_email_reminder' do
      submission = FactoryBot.create :submission
      expect(post: author_submission_send_email_reminder_path(submission.id)).to route_to(controller: 'author/submissions', action: 'send_email_reminder', submission_id: submission.id.to_s)
    end
  end
end
