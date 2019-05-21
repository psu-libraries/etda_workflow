# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FormatReviewUpdateService, type: :model do
  context 'it processes approved format review submissions' do
    it 'approves a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:approved] = true
      title = submission.title
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.respond_format_review
      expect(result[:msg]).to eql("The submission\'s format review information was successfully approved and returned to the author to collect final submission information.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/format_review_submitted")
      expect(submission.status).to eq('collecting final submission files')
      expect(submission.title).to eq(title)
    end
  end

  context 'it processes rejected format review submissions' do
    it 'rejects a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:rejected] = true
      semester = submission.semester
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.respond_format_review
      expect(result[:msg]).to eql("The submission\'s format review information was successfully rejected and returned to the author for revision.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/format_review_submitted")
      expect(submission.status).to eq('collecting format review files rejected')
      expect(submission.semester).to eq(semester)
    end
  end

  context 'it updates the record' do
    it 'updates a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response
      original_title = submission.title
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:update_format_review] = true
      params[:submission][:title] = 'a different title'
      params[:submission][:format_review_notes] = 'a note to you'
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.update_record
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      expect(submission.title).to eq('a different title')
      expect(submission.format_review_notes).to eq('a note to you')
      expect(original_title == submission.title).to be_falsey
    end
  end

  context 'it updates a format review submission and status' do
    it 'approves a format review' do
      submission = FactoryBot.create :submission, :waiting_for_format_review_response
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:approved] = true
      params[:submission][:title] = 'another different title'
      params[:submission][:format_review_notes] = 'another note to you'
      format_review_update_service = described_class.new(params, submission, 'testuser123')
      result = format_review_update_service.respond_format_review
      expect(result[:msg]).to eql("The submission's format review information was successfully approved and returned to the author to collect final submission information.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/format_review_submitted")
      expect(submission.status).to eq('collecting final submission files')
      expect(submission.title == 'another different title').to be_truthy
    end
  end
end
