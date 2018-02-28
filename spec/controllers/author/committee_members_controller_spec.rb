# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author::CommitteeMembersController, type: :controller do
  describe '#new' do
    it 'initializes an empty list of committee members for a submission' do
      submission = FactoryBot.create :submission, :collecting_committee
      expect(get: new_author_submission_committee_members_path(submission.id)).to route_to(controller: 'author/committee_members', action: 'new', submission_id: submission.id.to_s)
    end
  end

  describe '#create' do
    it 'creates the committee members for a submission' do
      submission = FactoryBot.create :submission, :collecting_committee
      expect(post: author_submission_committee_members_path(submission)).to route_to(controller: 'author/committee_members', action: 'create', submission_id: submission.id.to_s)
    end
  end

  describe '#edit' do
    it 'displays edit form for authors to edit committee members' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      expect(get: edit_author_submission_committee_members_path(submission)).to route_to(controller: 'author/committee_members', action: 'edit', submission_id: submission.id.to_s)
    end
  end

  describe '#update' do
    it 'updates committee members records with data included in a form' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      expect(patch: author_submission_committee_members_path(submission.id)).to route_to(controller: 'author/committee_members', action: 'update', submission_id: submission.id.to_s)
    end
  end
  describe '#show' do
    it 'shows a list of committee_members' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      expect(get: author_submission_committee_members_path(submission.id)).to route_to(controller: 'author/committee_members', action: 'show', submission_id: submission.id.to_s)
    end
  end
  describe '#refresh' do
    it 'refreshes committee information using information from lion path' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      expect(get: author_submission_refresh_committee_path(submission.id)).to route_to(controller: 'author/committee_members', action: 'refresh', submission_id: submission.id.to_s)
    end
  end
  describe '#autocomplete' do
    it 'autocompletes committee member name using data obtains from LDAP' do
      expect(get: committee_members_autocomplete_path).to route_to(controller: 'author/committee_members', action: 'autocomplete')
    end
  end
end
