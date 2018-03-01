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
    it 'creates a new submission for an author' do
      submission = FactoryBot.create :submission
      expect(get: edit_author_submission_path(submission.id)).to route_to(controller: 'author/submissions', action: 'edit', id: submission.id.to_s)
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
  describe '#refresh' do
    it 'refreshes submission information with lion path information' do
      submission = FactoryBot.create :submission
      expect(get: author_submission_refresh_path(submission.id)).to route_to(controller: 'author/submissions', action: 'refresh', submission_id: submission.id.to_s)
    end
  end
  # this may not be used
  # describe '#refresh_date_defended' do
  #   it 'refreshes the submission date_defended information with the date from lion path' do
  #     submission = FactoryBot.create :submission
  #     expect(get: author_submission_refresh_date_defended_path(submission.id)).to route_to(controller: 'author/submissions', action: 'refresh_date_defended', submission_id: submission.id.to_s)
  #   end
  # end
end
