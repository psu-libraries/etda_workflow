# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author::SubmissionFormatReviewController, type: :controller do
  describe '#edit' do
    it 'author edits a format review submission' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      expect(get: author_submission_edit_format_review_path(submission.id)).to route_to(controller: 'author/submission_format_review', action: 'edit', submission_id: submission.id.to_s)
    end
  end

  describe '#update' do
    it 'author updates a format review submission' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      expect(patch: author_submission_update_format_review_path(submission.id)).to route_to(controller: 'author/submission_format_review', action: 'update', submission_id: submission.id.to_s)
    end
  end

  describe '#show' do
    it 'displays a format review submission' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      expect(get: author_submission_format_review_path(submission.id)).to route_to(controller: 'author/submission_format_review', action: 'show', submission_id: submission.id.to_s)
    end
  end
end
