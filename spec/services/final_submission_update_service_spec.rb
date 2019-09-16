# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionUpdateService, type: :model do
  let(:final_count) { Partner.current.id == 'honors' ? 2 : 1 }
  let(:solr_result_success) { { error: false, solr_result: { "responseHeader" => { "status" => 0, "QTime" => 2 }, "initArgs" => ["defaults", ["config", "db-data-config.xml"]], "command" => "delta-import", "status" => "idle", "importResponse" => "", "statusMessages" => { "Total Requests made to DataSource" => "8", "Total Rows Fetched" => "0", "Total Documents Processed" => "0", "Total Documents Skipped" => "0", "Delta Dump started" => "2018-07-19 21:37:30", "Identifying Delta" => "2018-07-19 21:37:30", "Deltas Obtained" => "2018-07-19 21:37:30", "Building documents" => "2018-07-19 21:37:30", "Total Changed Documents" => "0", "Time taken" => "0:0:0.354" } } } }
  let(:committee_member) { FactoryBot.create :committee_member, created_at: DateTime.yesterday }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:approval_configuration) { FactoryBot.create :approval_configuration, configuration_threshold: 0, email_authors: true, use_percentage: false, email_admins: true }

  before do
    WorkflowMailer.deliveries = []
  end

  describe 'it processes approved final submissions' do
    it 'approves a final submission' do
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:approved] = true
      params[:submission][:title] = 'update this title'
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_final_submission
      expect(result[:msg]).to eql("The submission\'s final submission information was successfully approved.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/final_submission_submitted")
      expect(submission.status).to eq('waiting for committee review') unless current_partner.honors?
      expect(submission.status).to eq('waiting for publication release') if current_partner.honors?
      expect(submission.title).to eq('update this title')
      expect(submission.publication_release_terms_agreed_to_at).not_to be_nil
      expect(ActionMailer::Base.deliveries.count).to eq(submission.voting_committee_members.count + 1)
    end

    it 'approves a final submission and proceeds to publication release if committee approved' do
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response, committee_members: [committee_member]
      allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
      allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('approved')
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:approved] = true
      params[:submission][:title] = 'update this title'
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_final_submission
      expect(result[:msg]).to eql("The submission\'s final submission information was successfully approved.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/final_submission_submitted")
      expect(submission.status).to eq('waiting for publication release')
      expect(submission.title).to eq('update this title')
      expect(submission.publication_release_terms_agreed_to_at).not_to be_nil
      expect(WorkflowMailer.deliveries.count).to eq(2)
    end

    it 'rejects a final submission' do
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:rejected] = true
      params[:submission][:abstract] = 'this abstract is updated'
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_final_submission
      expect(result[:msg]).to eql("The submission\'s final submission information was successfully rejected and returned to the author for revision.")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/final_submission_submitted")
      expect(submission.status).to eq('collecting final submission files rejected')
      expect(submission.publication_release_terms_agreed_to_at).to be_nil
      expect(submission.has_agreed_to_terms).to be_falsey
      expect(submission.has_agreed_to_publication_release).to be_falsey
      expect(submission.abstract).to eq('this abstract is updated')
      expect(submission.committee_members.first.is_voting).to eq(false)
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Voting Attribute to 'False' at:/)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'updates a final submission' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:update_final] = true
      params[:submission][:title] = 'a different title'
      params[:submission][:final_submission_notes] = 'a note to you'
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_final_submission
      expect(result[:msg]).to eql(" Final submission information was successfully edited by an administrator")
      expect(result[:redirect_path]).to eql("/admin/#{submission.degree_type.slug}/final_submission_submitted")
      expect(submission.status).to eq('waiting for final submission response')
      expect(submission.title).to eq('a different title')
      expect(submission.final_submission_notes).to eq('a note to you')
      expect(submission.committee_members.first.is_voting).to eq(false)
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Voting Attribute to 'False' at: /)
      expect(ActionMailer::Base.deliveries.count).to eq(start_count + 0)
    end

    it 'edits a submission waiting to be released for publication' do
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_publication_release, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:update_final] = true
      params[:submission][:title] = 'a different title for release'
      params[:submission][:abstract] = 'a new abstract'
      params[:submission][:committee_members_attributes]["0"]['status'] = 'pending'
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_waiting_to_be_released
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      # ("/admin/submissions/#{submission.id}/edit")
      expect(submission.status).to eq('waiting for publication release')
      expect(submission.title).to eq('a different title for release')
      expect(submission.abstract).to eq('a new abstract')
      expect(submission.committee_members.first.status).to eq('pending')
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Review Status to 'Pending' at:*/)
      # No emails sent when edit only
      expect(ActionMailer::Base.deliveries.count).to eq(start_count)
    end
    it 'removes a submission from waiting to be released and does not send email' do
      allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :waiting_for_publication_release, committee_members: [committee_member]
      submission.final_submission_approved_at = Time.zone.now
      submission.final_submission_rejected_at = Time.zone.yesterday
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:rejected] = true
      params[:submission][:final_submission_notes] = 'a final note to you!!!'
      params[:submission][:committee_members_attributes]["0"]['status'] = 'rejected'
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_waiting_to_be_released
      expect(result[:msg]).to eql("Submission was removed from waiting to be released")
      expect(result[:redirect_path]).to eql(admin_submissions_release_final_submission_approved_path(submission.degree_type.slug.to_s))
      # ("/admin/#{submission.degree_type.slug}/final_submission_approved")
      expect(submission.status).to eq('waiting for final submission response')
      expect(submission.final_submission_notes).to eq('a final note to you!!!')
      expect(submission.final_submission_approved_at).to be(nil)
      expect(submission.final_submission_rejected_at).to be(nil)
      expect(submission.committee_members.first.status).to eq('rejected')
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Review Status to 'Rejected' at:*/)
      # no email updates for moving submission out of waiting to be released (this has not been published yet)
      expect(ActionMailer::Base.deliveries.count).to eq(start_count)
    end
    it 'edits a released submission but does not change the access level and does not send emails' do
      allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :released_for_publication, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:update_final] = true
      params[:submission][:title] = 'a different title for released submission'
      params[:submission][:abstract] = 'a different abstract'
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_released_submission
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      # ("/admin/submissions/#{submission.id}/edit")
      expect(submission.status).to eq('released for publication')
      expect(submission.title).to eq('a different title for released submission')
      expect(submission.abstract).to eq('a different abstract')
      expect(submission.committee_members.first.is_voting).to eq(false)
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Voting Attribute to 'False' at:/)
      expect(ActionMailer::Base.deliveries.count).to be == start_count + 0
    end
    it 'removes a submission from publication and does not send an email - access_level does not change' do
      allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)
      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :released_for_publication, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      params[:rejected] = true
      params[:submission][:abstract] = 'I am an abstract!!!!!'
      params[:submission][:committee_members_attributes]["0"]['notes'] = 'Some note'
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.respond_released_submission
      expect(result[:msg]).to eql("Submission for #{submission.author.first_name} #{submission.author.last_name} was successfully un-published.")
      expect(result[:redirect_path]).to eq(admin_edit_submission_path(submission.id.to_s))
      expect(submission.status).to eq('waiting for publication release')
      expect(submission.abstract).to eq('I am an abstract!!!!!')
      expect(submission.committee_members.first.is_voting).to eq(false)
      expect(submission.committee_members.first.notes).to match(/Some note\nThe admin user testuser123 changed Voting Attribute to 'False' at:/)
      expect(ActionMailer::Base.deliveries.count).to be == start_count + 0
    end
    it 'updates a final submission without changing the status' do
      allow_any_instance_of(SolrDataImportService).to receive(:delta_import).and_return(error: false)

      start_count = ActionMailer::Base.deliveries.count
      submission = FactoryBot.create :submission, :collecting_final_submission_files, committee_members: [committee_member]
      params = ActionController::Parameters.new
      params[:submission] = submission.attributes
      params[:submission][:committee_members_attributes] = { "0" => submission.committee_members.first.attributes }
      # params[:approved] = true
      title = submission.title
      params[:submission][:committee_members_attributes]["0"]['is_voting'] = false
      final_submission_update_service = described_class.new(params, submission, 'testuser123')
      result = final_submission_update_service.update_record
      expect(result[:msg]).to eql("The submission was successfully updated.")
      expect(result[:redirect_path]).to eql(admin_edit_submission_path(submission.id.to_s))
      expect(submission.status).to eq('collecting final submission files')
      expect(submission.title).to eq(title)
      expect(submission.committee_members.first.is_voting).to eq(false)
      expect(submission.committee_members.first.notes).to match(/\nThe admin user testuser123 changed Voting Attribute to 'False' at: /)
      expect(ActionMailer::Base.deliveries.count).to eq(start_count)
    end
  end
end
