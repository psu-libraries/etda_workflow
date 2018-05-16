# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionUpdateService, type: :model do
  let(:final_count) { Partner.current.id == 'honors' ? 2 : 1 }

  context 'it processes approved final submissions' do
    it 'approves a final submission' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:approved] = true
      params[:submission][:title] = 'update this title'
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.respond_final_submission
      expect(result[:msg]).to eql("The submission\'s final submission information was successfully approved.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/final_submission_submitted")
      expect(submission.status).to eq('waiting for publication release')
      expect(submission.title).to eq('update this title')
      expect(submission.publication_release_terms_agreed_to_at).not_to be_nil
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + final_count)
    end
  end

  context 'it processes rejected final submissions' do
    it 'rejects a final submission' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:rejected] = true
      params[:submission][:abstract] = 'this abstract is updated'
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.respond_final_submission
      expect(result[:msg]).to eql("The submission\'s final submission information was successfully rejected and returned to the author for revision.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/final_submission_submitted")
      expect(submission.status).to eq('collecting final submission files rejected')
      expect(submission.publication_release_terms_agreed_to_at).to be_nil
      expect(submission.has_agreed_to_terms).to be_falsey
      expect(submission.has_agreed_to_publication_release).to be_falsey
      expect(submission.abstract).to eq('this abstract is updated')
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 0)
    end
  end

  context 'it updates a final submission' do
    it 'updates a final submission' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:update_final] = true
      params[:submission][:title] = 'a different title'
      params[:submission][:final_submission_notes] = 'a note to you'
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.respond_final_submission
      expect(result[:msg]).to eql(" Final submission information was successfully edited by an administrator")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/final_submission_submitted")
      expect(submission.status).to eq('waiting for final submission response')
      expect(submission.title).to eq('a different title')
      expect(submission.final_submission_notes).to eq('a note to you')
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 0)
    end
  end

  context 'it updates submissions waiting to be released' do
    it 'updates submission' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_publication_release
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:update_final] = true
      params[:submission][:title] = 'a different title for release'
      params[:submission][:abstract] = 'a new abstract'
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.respond_waiting_to_be_released
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      # ("/admin/submissions/#{submission.id}/edit")
      expect(submission.status).to eq('waiting for publication release')
      expect(submission.title).to eq('a different title for release')
      expect(submission.abstract).to eq('a new abstract')
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 1)
    end
    it 'removes a submission from waiting to be released' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_publication_release
      submission.final_submission_approved_at = Time.zone.now
      submission.final_submission_rejected_at = Time.zone.yesterday
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:rejected] = true
      params[:submission][:final_submission_notes] = 'a final note to you!!!'
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.respond_waiting_to_be_released
      expect(result[:msg]).to eql("Submission was removed from waiting to be released")
      expect(result[:redirect_path]).to eql(admin_submissions_release_final_submission_approved_path(submission.degree_type.slug.to_s))
      # ("/admin/#{submission.degree_type.slug}/final_submission_approved")
      expect(submission.status).to eq('waiting for final submission response')
      expect(submission.final_submission_notes).to eq('a final note to you!!!')
      expect(submission.final_submission_approved_at).to be(nil)
      expect(submission.final_submission_rejected_at).to be(nil)
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 1)
    end
  end
  context 'it updates submissions released submission' do
    it 'updates a released submission' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :released_for_publication
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:update_final] = true
      params[:submission][:title] = 'a different title for released submission'
      params[:submission][:abstract] = 'a different abstract'
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.respond_released_submission
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      # ("/admin/submissions/#{submission.id}/edit")
      expect(submission.status).to eq('released for publication')
      expect(submission.title).to eq('a different title for released submission')
      expect(submission.abstract).to eq('a different abstract')
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 1)
    end
    it 'removes a submission from publication' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :released_for_publication
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:rejected] = true
      params[:submission][:abstract] = 'I am an abstract!!!!!'
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.respond_released_submission
      expect(result[:msg]).to eql("Submission for #{submission.author.first_name} #{submission.author.last_name} was successfully un-published")
      expect(result[:redirect_path]).to eq(admin_edit_submission_path(submission.id.to_s))
      expect(submission.status).to eq('waiting for publication release')
      expect(submission.abstract).to eq('I am an abstract!!!!!')
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 0)
    end
  end
  context 'it updates the record' do
    it 'updates a final submission' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :collecting_final_submission_files
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      # params[:approved] = true
      title = submission.title
      final_submission_update_service = described_class.new(params, submission)
      result = final_submission_update_service.update_record
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      # ("/admin/submissions/#{submission.id}/edit")
      expect(submission.status).to eq('collecting final submission files')
      expect(submission.title).to eq(title)
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 1)
    end
  end
end
